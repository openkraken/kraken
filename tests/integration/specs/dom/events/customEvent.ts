describe('CustomEvent', () => {
    it('should exist CustomEvent global object', () => {
        expect(CustomEvent).toBeDefined();
        expect(() => {
            new CustomEvent('test');
        }).not.toThrow();
    });

    it('should work as expected', () => {
        let customEvent = new CustomEvent('customEvent', { detail: 'detail message' });
        expect(customEvent.detail).toEqual('detail message');
    });

    it('should dispatch custom event', (done) => {
        document.body.addEventListener('customEvent', (event: CustomEvent) => {
            expect(event.detail).toEqual('detail message');
            done();
        });
        document.body.dispatchEvent(new CustomEvent('customEvent', { 
            detail: 'detail message'
        }));
    });
});
  