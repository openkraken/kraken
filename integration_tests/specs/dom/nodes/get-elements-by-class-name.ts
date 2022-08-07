/**
 * Test DOM API for
 * - document.getElementsByClassName
 */
describe('Document getElementsByClassName', () => {
  it('basic', () => {
    expect(document.getElementsByClassName('className').length).toBe(0);
  });

  it('work with element', () => {
    const div = document.createElement('div');
    div.className = 'className';
    document.body.appendChild(div);

    expect(document.getElementsByClassName('className').length).toBe(1);
  });

  it('work with element when element use setAttribute to set classname', () => {
    const div = document.createElement('div');
    div.setAttribute('class', 'className');
    document.body.appendChild(div);

    expect(document.getElementsByClassName('className').length).toBe(1);
  });

  it('work with some elements', () => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;

      div.className = `class-${index}`;
      document.body.appendChild(div);
    })

    expect(document.getElementsByClassName('class-1').length).toBe(1);
  });

  it('work with some elements when more than one class', () => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;

      div.className = `class-${index} cc`;
      document.body.appendChild(div);
    })

    expect(document.getElementsByClassName('class-1').length).toBe(1);
  });

  it('work with some elements when more than one class of query', () => {
    ['red', 'black', 'green', 'yellow', 'blue'].forEach((item, index) => {
      const div = document.createElement('div')
      div.style.width = '100px';
      div.style.height = '100px';
      div.style.backgroundColor = item;

      div.className = `class-${index} cc`;
      document.body.appendChild(div);
    })

    expect(document.getElementsByClassName('class-1 cc').length).toBe(1);
  });
})
