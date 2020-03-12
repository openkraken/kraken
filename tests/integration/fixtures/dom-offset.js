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
it('DOM Element offset', () => {
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
  div.style.width = div.style.height = '200px';
  div.style.backgroundColor = 'red';

  document.body.appendChild(div);
  let str = '';
  RECT_PROPERTIES.forEach((key) => {
    str += `${key}: ${div[key]}px `;
  });

  document.body.appendChild(document.createTextNode(str));
});
