describe('Display block', () => {
  it('001', async () => {
    var container = document.createElement('div');
    container.style.width = '300px';
    container.style.height = '300px';
    container.style.backgroundColor = 'red';

    var box = document.createElement('div');
    box.style.width = '150px';
    box.style.height = '150px';
    box.style.backgroundColor = 'green';

    container.appendChild(box);
    document.body.appendChild(container);
    await snapshot();
  });

  it('002', async () => {
    var container = document.createElement('div');
    container.style.width = '300px';
    container.style.height = '300px';
    container.style.backgroundColor = 'red';

    document.body.appendChild(container);
    await snapshot();
  });
});
