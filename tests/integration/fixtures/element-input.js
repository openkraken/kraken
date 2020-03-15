it('element input', () => {
  const input = document.createElement('input');
  input.style.width = '60px';
  input.style.fontSize = '16px';
  input.setAttribute('value', 'Hello World');
  document.body.appendChild(input);
});
