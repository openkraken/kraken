describe('head', () => {
  it('should exist', () => {
    expect(document.head).toBeDefined();
    expect(document.head.appendChild).toBeDefined();
  });

  it('children should display none ', async () => {
    const title = <title>Hi</title>;
    const style = <style>{"h1 {color:red;}"}</style>;
    const link = <link rel="stylesheet" href="style.css" />;
    const meta = <meta charset="utf-8" />;
    const div = <div>PASS if only this text.</div>;

    document.body.appendChild(title);
    document.body.appendChild(style);
    document.body.appendChild(link);
    document.body.appendChild(meta);
    document.body.appendChild(div);

    expect(document.body.children.length).toBe(5);
    expect(document.body.children[0].tagName).toBe('TITLE');
    expect(document.body.children[1].tagName).toBe('STYLE');
    expect(document.body.children[2].tagName).toBe('LINK');
    expect(document.body.children[3].tagName).toBe('META');
    await snapshot();
  });
});
