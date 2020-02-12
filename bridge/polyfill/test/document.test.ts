import '../src/document/index';

describe('document', () => {
  let messages: string[] = [];
  beforeEach(() => {
    messages = [];
    // @ts-ignore
    global.__kraken_js_to_dart__ = (msg) => messages.push(msg);
  });

  it('createElement', () => {
    var div = document.createElement('div');
    var span = document.createElement('span');
    var textNode = document.createTextNode('helloworld');
    span.appendChild(textNode);
    div.appendChild(span);
    document.body.appendChild(div);
    expect(messages).toMatchSnapshot('createElement');
    expect(div.parentNode!.nodeName).toMatch('BODY');
    expect(span.parentNode!.nodeName).toMatch('DIV');
    expect(textNode.parentNode!.nodeName).toMatch('SPAN');
  });

  it('insertBefore', () => {
    var div = document.createElement('div');
    var span = document.createElement('span');
    var textNode = document.createTextNode('helloworld');
    span.appendChild(textNode);
    div.appendChild(span);
    document.body.appendChild(div);

    var insertText = document.createTextNode('inserted');
    var insertSpan = document.createElement('span');
    insertSpan.appendChild(insertText);
    div.insertBefore(insertSpan, span);
    expect(messages).toMatchSnapshot('insertBefore');
  });

  it('setStyle', () => {
    let div = document.createElement('div');
    div.style.fontSize = '12px';
    expect(messages).toMatchSnapshot('setStyle');
  });
});
