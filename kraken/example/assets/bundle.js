let div;

for(var i = 1; i < 10; i++) {
for(var j = 1; j < 40; j++) {
for(var k = 1; k < 25; k++) {
   div = document.createElement('div');
   div.style.height = '50px';
   div.onappear = (function(i, j, k){ return x => console.log('appear', i, j, k)})(i, j, k);
   div.appendChild(document.createTextNode(`${i} ${j} ${k}`));
   document.body.appendChild(div);
}
}
}
//
//    const img = document.createElement('img');
//    img.setAttribute('loading', 'lazy');
//    img.style.width = '60px';
//    img.style.height = '60px';
//    img.style.background = 'red';
//
//    let div = document.createElement('div');
//    div.style.width = '100px';
//    div.style.height = '2000px';
//    div.style.background = 'yellow';
//
//    document.body.appendChild(div);
//    document.body.appendChild(img);
//
//    img.onload = async () => {
//      console.log('onload');
//    };
//    img.src = 'https://gw.alicdn.com/tfs/TB1CxCYq5_1gK0jSZFqXXcpaXXa-128-90.png?1';
//    img.onappear = function(){ console.log('appear')};

//    window.scroll(0, 2000);
