describe('Navigator', () => {
  it('connectivity', async () => {
    let connection = await navigator.connection.getConnectivity();
    expect(connection.isConnected).toBeTrue();
    expect(['wifi', '4g'].includes(connection.type)).toBeTrue();
  });

  it('hardwareConcurrency', () => {
    expect(navigator.hardwareConcurrency > 0).toBeTrue();
  });

  it('platform', async () => {
    expect(navigator.platform).toBeDefined();
  });

  it('appName', () => {
    expect(navigator.appName).toBeDefined();
  });

  it('appVersion', () => {
    expect(navigator.appVersion).toBeDefined();
  });

  it('language', async () => {
    expect(navigator.language).toBeDefined();
    expect(navigator.language.includes('-')).toBeTrue();
  });

  it('languages', async () => {
    expect(navigator.languages instanceof Array).toBeTrue();
    expect(navigator.languages[0]).toBeDefined();
    expect(navigator.languages[0].includes('-')).toBeTrue();
  });

  it('userAgent', () => {
    expect(navigator.userAgent).toMatch(/Kraken/);
  });

  it('clipboard', async () => {
    const text = String(new Date());
    await navigator.clipboard.writeText(text);
    const data = await navigator.clipboard.readText();
    expect(data).toBe(text);
  });
});
