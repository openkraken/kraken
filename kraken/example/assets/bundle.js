var text = document.createTextNode('Hello World!');
var p = document.createElement('p');
p.style.textAlign = 'center';
p.appendChild(text);
document.body.appendChild(p);