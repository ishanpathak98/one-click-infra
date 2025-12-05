#!/bin/bash
set -e

# Update and install requirements
yum update -y
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs jq awslogs

# Ensure SSM agent is running (Amazon Linux 2 usually has it)
systemctl enable amazon-ssm-agent || true
systemctl start amazon-ssm-agent || true

# Create app user and directory
useradd -m appuser || true
mkdir -p /home/appuser/app
chown -R appuser:appuser /home/appuser/app

# Write app files (embedded by Terraform)
cat > /home/appuser/app/server.js <<'EOF'
{{file "app/server.js"}}
EOF

cat > /home/appuser/app/package.json <<'EOF'
{{file "app/package.json"}}
EOF

# Install node modules
cd /home/appuser/app
npm install --production || true
chown -R appuser:appuser /home/appuser/app

# Setup systemd service
cat > /etc/systemd/system/simple-api.service <<'EOF'
[Unit]
Description=Simple Node API
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser/app
ExecStart=/usr/bin/node /home/appuser/app/server.js
Restart=always
Environment=PORT=8080

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable simple-api
systemctl start simple-api

# Create log dir and stream journals to a file
mkdir -p /var/log/simple-api
chown appuser:appuser /var/log/simple-api

cat > /usr/local/bin/journald-to-file.sh <<'EOF'
#!/bin/bash
journalctl -fu simple-api.service -o short-iso | while read line; do
  echo "$line" >> /var/log/simple-api/app.log
done
EOF
chmod +x /usr/local/bin/journald-to-file.sh
nohup /usr/local/bin/journald-to-file.sh >/dev/null 2>&1 &

# Configure awslogs
cat > /etc/awslogs/config/oneclick-api.conf <<'EOF'
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/simple-api/app.log]
file = /var/log/simple-api/app.log
log_group_name = /oneclick-api/app
log_stream_name = {instance_id}
datetime_format = %Y-%m-%d %H:%M:%S
EOF

systemctl enable awslogsd
systemctl restart awslogsd || true
