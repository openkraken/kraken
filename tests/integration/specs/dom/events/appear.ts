describe('Appear Event', () => {
  it('appear & disappear', () => {
    return new Promise(async (resolve, reject) => {
      const div = document.createElement('div');
      div.style.width = '300px';
      div.style.height = '300px';
      div.style.backgroundColor = 'red';

      let triggered = false;
      div.addEventListener('disappear', async () => {
        // Only trigger once, in case of test case error.
        if (triggered) return;
        triggered = true;
        div.style.backgroundColor = 'green';
        div.style.bottom = '0';
        await expectAsync(div.toBlob(1.0)).toMatchImageSnapshot('disappeared');
        resolve();
      });

      setTimeout(reject, 500);
      setTimeout(() => {
        div.style.position = 'absolute';
        div.style.bottom = '-600px';
      }, 100);

      document.body.appendChild(div);

      await expectAsync(div.toBlob(1.0)).toMatchImageSnapshot('original');
    });
  });
});
