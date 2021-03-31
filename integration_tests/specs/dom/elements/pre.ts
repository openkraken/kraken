describe('PreElement', () => {
  it('basic', async () => {
    const pre = document.createElement('pre');
    pre.appendChild(createText(`
Text in a pre element
is displayed in a fixed-width
font, and it preserves
both      spaces and
line breaks
    `));

    document.body.appendChild(pre);
    await matchViewportSnapshot();
  });
});
