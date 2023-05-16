const http = require('http');
const cowsay = require('cowsay');
const quote = require('inspirational-quotes');

const port = process.env.PORT || 80;

http.createServer(function(request, response) {
    response.writeHead(200, { 'Content-Type': 'text/plain' });
    const text = quote.getRandomQuote();
    const output = cowsay.think({ text, r: true });
    response.end(output);
}).listen(port);

console.log(`Server running at http://localhost:${port}`);