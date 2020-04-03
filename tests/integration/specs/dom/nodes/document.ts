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

});
