/* app/server.js */
const http = require('http');

const PORT = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('ok');
    return;
  }

  if (req.url === '/') {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello from private EC2 behind ALB\n');
    return;
  }

  res.writeHead(404, {'Content-Type': 'text/plain'});
  res.end('not found');
});

server.listen(PORT, () => {
  console.log(`App listening on ${PORT}`);
});
