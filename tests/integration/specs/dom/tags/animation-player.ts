describe('AnimationPlayer', () => {

  describe('Flare', () => {
    it('bacis usage with teddy bear', async () => {
      const ASSET = 'https://kraken.oss-cn-hangzhou.aliyuncs.com/data/Teddy.flr';
      const animationPlayer = document.createElement('animation-player') as any;
      animationPlayer.setAttribute('type', 'flare');
      animationPlayer.setAttribute('src', ASSET);
      Object.assign(animationPlayer.style, {
        width: '100vw',
        height: '100vh',
        objectFit: 'contain',
      });

      document.body.appendChild(animationPlayer);

      // Need to impl onload event.
      await sleep(1);
      await matchScreenshot();

      animationPlayer.play('hands_up');
      // Wait for animation end.
      // Need to impl animation_end event.
      await sleep(1);

      await matchScreenshot();
    });
  });
});
