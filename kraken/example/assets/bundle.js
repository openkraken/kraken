var text1 = document.createTextNode('Hello Kraken!');
var br = document.createElement('br');
var text2 = document.createTextNode('你好，北海！');
var p = document.createElement('p');
p.className = 'p';
p.style.textAlign = 'center';
p.appendChild(text1);
p.appendChild(br);
p.appendChild(text2);

document.body.appendChild(p);
