it('img', () => {
  // throw an error to urge someone to add load event on img.
  throw new Error('img 需要load事件');
  var img = document.createElement('img');
  document.body.appendChild(img);

  img.style.width = '60px';
  img.setAttribute('src', '//gw.alicdn.com/tfs/TB1MRC_cvb2gK0jSZK9XXaEgFXa-1701-1535.png');
});
