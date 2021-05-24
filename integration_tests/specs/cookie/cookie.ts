describe('Cookie', () => {
  it('works with cookie getter and setter', async () => {
    document.cookie = "name=oeschger";
    document.cookie = "favorite_food=tripe";
    document.body.appendChild(document.createTextNode(document.cookie));
    await snapshot();
  });
});
