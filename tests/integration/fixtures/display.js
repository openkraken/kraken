var el = document.createElement('div');
var child1 = document.createElement('div');
child1.style.backgroundColor = 'black';

var blockContainer = document.createElement('div');
blockContainert.style.width = blockContainert.style.height = '100rpx';
blockContainert.style.display = 'block';
blockContainert.style.backgroundColor = 'blue';
var textBlock = document.createTextNode('block');
blockContainert.appendChild(textBlock);
child1.appendChild(blockContainert);

var flexContainer = document.createElement('div');
flexContainer.style.width = '120rpx';
flexContainer.style.height = '100rpx';
flexContainer.style.backgroundColor = 'green';
flexContainer.style.display = 'flex';
var textFlex = document.createTextNode('flex');
flexContainer.appendChild(textFlex);
child1.appendChild(flexContainer);

var inlineFlexContainer = document.createElement('div');
inlineFlexContainer.style.width = '150rpx';
inlineFlexContainer.style.height = '100rpx';
inlineFlexContainer.style.backgroundColor = 'purple';
inlineFlexContainer.style.display = 'inline-flex';
var textInlineFlex = document.createTextNode('inline-flex');
inlineFlexContainer.appendChild(textInlineFlex);
child1.appendChild(flexContainer);


var inlineContainer = document.createElement('span');
inlineContainer.style.width = '200rpx';
inlineContainer.style.height = '150rpx';
inlineContainer.style.backgroundColor = 'yellow';
inlineContainer.appendChild(document.createTextNode('inline'));
child1.appendChild(inlineContainer);

var inlineBlockContainer = document.createElement('span');
span.style.display = 'inline-block';
span.style.width = '200rpx';
span.style.height = '100rpx';
span.style.backgroundColor = 'brown';
span.appendChild(document.createTextNode('inline-block'));
child1.appendChild(span);

document.body.appendChild(child1);
