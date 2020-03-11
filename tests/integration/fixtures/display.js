it('display', () => {
  var el = document.createElement('div');
  var child1 = document.createElement('div');
  child1.style.backgroundColor = 'black';

  var blockContainer = document.createElement('div');
  blockContainer.style.width = blockContainer.style.height = '100rpx';
  blockContainer.style.display = 'block';
  blockContainer.style.backgroundColor = 'blue';
  var textBlock = document.createTextNode('block');
  blockContainer.appendChild(textBlock);
  child1.appendChild(blockContainer);

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
  child1.appendChild(inlineFlexContainer);


  var inlineContainer = document.createElement('span');
  inlineContainer.style.width = '200rpx';
  inlineContainer.style.height = '150rpx';
  inlineContainer.style.backgroundColor = 'yellow';
  inlineContainer.appendChild(document.createTextNode('inline'));
  child1.appendChild(inlineContainer);

  var inlineBlockContainer = document.createElement('span');
  inlineBlockContainer.style.display = 'inline-block';
  inlineBlockContainer.style.width = '200rpx';
  inlineBlockContainer.style.height = '100rpx';
  inlineBlockContainer.style.backgroundColor = 'brown';
  inlineBlockContainer.appendChild(document.createTextNode('inline-block'));
  child1.appendChild(inlineBlockContainer);

  document.body.appendChild(child1);
});