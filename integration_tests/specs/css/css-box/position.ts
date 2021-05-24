describe('Box position', () => {
  it('should work with basic samples', async () => {
    var container = document.createElement('div');
    var div1 = document.createElement('div');
    var div2 = document.createElement('span');


    container.style.width = '300px';
    container.style.height = '800px';
    container.style.backgroundColor = '#999';

    div1.style.position = 'absolute';
    div1.style.width = '100px';
    div1.style.height = '200px';
    div1.style.backgroundColor = 'red';

    div2.style.position = 'absolute';
    div2.style.width = '100px';
    div2.style.height = '100px';
    div2.style.top = '50px';
    div2.style.backgroundColor = 'green';

    container.style.marginLeft = '50px';
    container.style.position = 'relative';
    container.style.top = '100px';


    container.appendChild(div1);
    container.appendChild(div2);
    document.body.appendChild(container);

    await snapshot();
  });
});
