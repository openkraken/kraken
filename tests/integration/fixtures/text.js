const span = document.createElement('span');
const text = document.createTextNode('hello world');
span.appendChild(text);

span.style.fontSize = '80px';
span.style.textDecoration = 'line-through';
document.body.appendChild(span);
