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

  it('offsetTop and offsetLeft works when positioned parent found', async () => {
    let item1;
    let div1 = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          backgroundColor: 'coral',
        },
      });
    let div2 = createElement(
      'div',
      {
        style: {
          position: 'relative',
          width: '100px',
          height: '100px',
          marginLeft: '100px',
          backgroundColor: 'green',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            backgroundColor: 'yellow',
          }
        })),
      ]
    );

    BODY.appendChild(div1);
    BODY.appendChild(div2);

    expect(item1.offsetTop).toBe(0);
    expect(item1.offsetLeft).toBe(0);
  });
    
  it('offsetTop and offsetLeft works when positioned parent not found', async () => {
    let item1;
    let div1 = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          backgroundColor: 'coral',
        },
      });
    let div2 = createElement(
      'div',
      {
        style: {
          width: '100px',
          height: '100px',
          marginLeft: '100px',
          backgroundColor: 'green',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            backgroundColor: 'yellow',
          }
        })),
        (createElement('div', {
          style: {
            width: '50px',
            height: '1000px',
            backgroundColor: 'red',
          }
        })),
      ]
    );

    BODY.appendChild(div1);
    BODY.appendChild(div2);

    document.documentElement.scrollTo(0, 80);
 
    expect(item1.offsetTop).toBe(100);
    expect(item1.offsetLeft).toBe(100);
  });

});
