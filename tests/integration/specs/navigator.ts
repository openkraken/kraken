describe('Navigator', () => {
  it('connectivity', async () => {
    let connection = await navigator.connection.getConnectivity();
    expect(connection.isConnected).toBeTrue();
    expect(['wifi', '4g'].includes(connection.type)).toBeTrue();
  });

  it('hardwareConcurrency', () => {
    expect(navigator.hardwareConcurrency > 0).toBeTrue();
  });

  it('getDeviceInfo', async () => {
    let deviceInfo = await navigator.getDeviceInfo();
    expect(deviceInfo.brand).toBe('Apple');
    expect(deviceInfo.isPhysicalDevice).toBeTrue();
    expect(deviceInfo.platformName).toBe('Mac OS');
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
