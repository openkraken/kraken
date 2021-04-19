/**
 * Test DOM API for Element:
 * - Element.prototype.offsetTop
 * - Element.prototype.offsetLeft
 * - Element.prototype.offsetWidth
 * - Element.prototype.offsetHeight
 * - Element.prototype.clientWidth
 * - Element.prototype.clientHeight
 * - Element.prototype.clientLeft
 * - Element.prototype.clientTop
 * - Element.prototype.scrollTop
 * - Element.prototype.scrollLeft
 * - Element.prototype.scrollHeight
 * - Element.prototype.scrollWidth
 */
describe('Offset api', () => {
  it('should work', async () => {
    const RECT_PROPERTIES = [
      'offsetTop',
      'offsetLeft',
      'offsetWidth',
      'offsetHeight',

      'clientWidth',
      'clientHeight',
      'clientLeft',
      'clientTop',

      'scrollTop',
      'scrollLeft',
      'scrollHeight',
      'scrollWidth',
    ];

    const div = document.createElement('div');
    div.style.width = '150px';
    div.style.height = '120px';
    div.style.backgroundColor = 'red';

    document.body.appendChild(div);
    let str = '';
    RECT_PROPERTIES.forEach(key => {
      str += `${key}: ${div[key]}px `;
    });

    document.body.appendChild(document.createTextNode(str));

    await snapshot();
  });
});
