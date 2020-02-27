const div = document.createElement('div');
div.style.margin = '20rpx 30rpx 30rpx 30rpx';
div.style.backgroundColor = 'blue';

document.body.appendChild(div);

const div2 = document.createElement('div');
div2.style.width = '10px';
div2.style.height = '10px';

div.appendChild(div2);

const div3 = document.createElement('div');
div3.style.width = '200px';
div3.style.height = '200px';
div3.style.backgroundImage = 'radial-gradient(50%, red 0%, yellow 20%, blue 80%)';

document.body.appendChild(div3);
