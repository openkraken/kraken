it('connectivity', async () => {
  let connection = await navigator.connection.getConnectivity();
  assert.equal(connection.isConnected, true);
  assert.equal(['wifi', '4g'].includes(connection.type), true);
});

it('hardwareConcurrency', () => {
  assert.equal(navigator.hardwareConcurrency > 0, true)
});

it('getDeviceInfo', async () => {
  let deviceInfo = await navigator.getDeviceInfo();
  assert.equal(deviceInfo.brand, 'Apple');
  assert.equal(deviceInfo.isPhysicalDevice, true);
  assert.equal(deviceInfo.platformName, 'Mac OS');
});