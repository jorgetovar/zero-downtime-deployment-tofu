const http = require('http');

const server = http.createServer((req, res) => {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello, AWS Community Builders! The best way to learn is teaching 👨‍🏫.\n');
});

const port = 8080;
server.listen(port, () => {
    console.log(`Listening on port ${port}`);
});
