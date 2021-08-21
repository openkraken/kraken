describe('headings', () => {
  it('has default margin', async () => {
    const headings = <div>
      <h1>Heading 1</h1>
      <h2>Heading 2</h2>
      <h3>Heading 3</h3>
      <h4>Heading 4</h4>
      <h5>Heading 5</h5>
      <h6>Heading 6</h6>
    </div>;

    document.body.appendChild(headings);
    await snapshot();
  });
});
