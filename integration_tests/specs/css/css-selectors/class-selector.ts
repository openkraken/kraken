describe('css class selector', () => {
  it('style added', async () => {
    const style = <style>{`.red { color: red; }`}</style>;
    const div = <div class="red">{'It should red color'}</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
  });

  it('style removed', async () => {
    const style = <style>{`.red { color: red; }`}</style>;
    const div = <div class="red">{'It should from red to black color'}</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
    document.head.removeChild(style);
    await snapshot();
  });

  it('style removed later', async (done) => {
    const style = <style>{`.blue { color: blue; }`}</style>;
    const div = <div class="blue">{'It should from blue to black color'}</div>;
    document.head.appendChild(style);
    document.body.appendChild(div);
    await snapshot();
    requestAnimationFrame(async () => {
      document.head.removeChild(style);
      await snapshot();
      done();
    });
  });

  it('two style added', async () => {
    const style1 = <style>{`.txt { color: red; }`}</style>;
    const style2 = <style>{`.txt { font-size: 20px; }`}</style>;
    const div = <div class="txt">{'It should red color and 20px'}</div>;
    document.head.appendChild(style1);
    document.body.appendChild(div);
    document.head.appendChild(style2);

    await snapshot();
  });

  it('one style removed', async () => {
    const style1 = <style>{`.txt { color: red; }`}</style>;
    const style2 = <style>{`.txt { font-size: 20px; }`}</style>;
    const div = <div class="txt">{'It should black color and 20px'}</div>;
    document.head.appendChild(style1);
    document.body.appendChild(div);
    document.head.appendChild(style2);
    document.head.removeChild(style1);

    await snapshot();
  });

  it('one inline style removed', async () => {
    const style1 = <style>{`.txt { color: red; }`}</style>;
    const style2 = <style>{`.txt { font-size: 20px; }`}</style>;
    const div = <div style={{color: 'yellow'}} class="txt">{'It should from yellow to red and 20px to 16px'}</div>;
    document.head.appendChild(style1);
    document.head.appendChild(style2);
    document.body.appendChild(div);
    await snapshot();
    div.style.removeProperty('color');
    await snapshot();
    document.head.removeChild(style2);
    await snapshot();
  });
});
