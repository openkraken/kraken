const http = require('http');
const URL = require('url');

http.createServer(((req, res) => {
  const url = req.url;
  const query = URL.parse(url);

  let body = '';
  req.on('data', chunk => {
    body += chunk.toString();
  });
  req.on('end', () => {
    res.end(JSON.stringify({
      method: 'POST',
      data: body
    }))
  });

  res.end(JSON.stringify({
    method: 'GET',
    data: JSON.stringify(query.query)
  }));
  console.log('server listening at :9450');
})).listen(9450);