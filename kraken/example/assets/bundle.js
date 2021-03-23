var text = document.createTextNode('Hello World!');
var p = document.createElement('p');
p.style.textAlign = 'center';
p.style.width = '200px';
p.style.height = '100px';
p.style.border = '1px solid #000';
p.style.margin = '0 auto';
p.appendChild(text);
document.body.appendChild(p);
