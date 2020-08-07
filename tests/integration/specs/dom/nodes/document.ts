/**
 * Test DOM API for
 * - document.createElement
 * - document.createTextNode
 * - document.createComment
 * - document.documentElement
 */
describe('Document api', () => {
  it('should work', async () => {
    const container = document.createElement('div');
    container.appendChild(document.createTextNode('This is a text node.'));
    container.appendChild(document.createComment('This is a comment'));
    document.body.appendChild(container);

    await matchScreenshot();
  });

  it('documentElement', async () => {
    const documentElementWidth = document.documentElement.clientWidth;
    const documentElementHeight = document.documentElement.clientHeight;

    const text1 = document.createTextNode('documentElement width: ' + documentElementWidth + '\n');
    document.body.appendChild(text1);

    const text2 = document.createTextNode('documentElement height: ' + documentElementHeight + '\n');
    document.body.appendChild(text2);

    await matchScreenshot();
  });

  it('document.all', () => {
    expect(document.all).not.toBeUndefined();
    expect(document.all.length).toBeGreaterThan(0);
  });

  it('document.getElementById', () => {
    const main = document.createElement('div');
    main.setAttribute('id', 'main');
    expect(document.getElementById('main')).toBeNull();

    document.body.appendChild(main);
    expect(document.getElementById('main') === main).toBeTrue();
    document.body.removeChild(main);
    expect(document.getElementById('main')).toBeNull();

    const newDiv = document.createElement('div');
    newDiv.setAttribute('id', 'newDiv');
    document.body.appendChild(newDiv);
    newDiv.removeAttribute('id');
    expect(document.getElementById('newDiv')).toBeNull();

    const child = document.createElement('p');
    child.setAttribute('id', 'child');
    newDiv.setAttribute('id', 'newDiv');
    document.body.insertBefore(child, newDiv);
    expect(document.getElementById('child') === child).toBeTrue();

    child.remove();
    expect(document.getElementById('child')).toBeNull();

    const newChild = document.createElement('p');
    newChild.setAttribute('id', 'newChild');
    document.body.replaceChild(newChild, newDiv);
    expect(document.getElementById('newDiv')).toBeNull();
    expect(document.getElementById('newChild') === newChild).toBeTrue();
  })
  
});
