describe('background-attachment', () => {
  // @TODO: Support background-attachment: fixed.
  xit('fixed', async () => {
    let container = createElementWithStyle('div', {
      'background-attachment': 'fixed',
      'background-position': '1em 5em',
      'background-image':
        'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/cat.png)',
      'background-repeat': 'no-repeat',
      border: '1px solid blue',
      height: '250px',
      overflow: 'scroll',
      width: '250px',
    });
    let text = createText(
      'Cupcake ipsum dolor sit. Amet applicake bonbon chocolate cake ice cream. Bear claw tootsie roll cotton candy biscuit. Sweet roll chupa chups gingerbread sugar plum icing muffin biscuit. Chocolate cake wafer pastry tart macaroon danish topping ice cream. Jujubes liquorice candy canes faworki. Jujubes cake caramels faworki pie cake sweet roll. Tiramisu sesame snaps candy cheesecake brownie souffle biscuit. Danish chupa chups donut. Donut tart marshmallow biscuit lollipop chupa chups jelly beans faworki. Sugar plum wafer faworki marshmallow brownie ice cream cotton candy marshmallow marzipan. Cheesecake gummi bears cupcake sweet croissant cookie chocolate bar sweet roll. Halvah cupcake carrot cake souffle carrot cake chocolate cake pastry gummi bears muffin. Sweet roll candy gingerbread dessert tart. Pastry oat cake jelly beans.'
    );
    append(container, text);
    append(BODY, container);
    await sleep(1);
    await snapshot(container);
  });

  it('local', async () => {
    let container = createElementWithStyle('div', {
      'background-attachment': 'local',
      'background-image':
        'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/cat.png)',
      'background-repeat': 'no-repeat',
      'background-color': 'yellow',
      border: '10px solid rgba(0, 0, 0, 0.3)',
      height: '250px',
      overflow: 'scroll',
      width: '250px',
      padding: '100px 0 0',
    });
    let text = createText(
      'Cupcake ipsum dolor sit. Amet applicake bonbon chocolate cake ice cream. Bear claw tootsie roll cotton candy biscuit. Sweet roll chupa chups gingerbread sugar plum icing muffin biscuit. Chocolate cake wafer pastry tart macaroon danish topping ice cream. Jujubes liquorice candy canes faworki. Jujubes cake caramels faworki pie cake sweet roll. Tiramisu sesame snaps candy cheesecake brownie souffle biscuit. Danish chupa chups donut. Donut tart marshmallow biscuit lollipop chupa chups jelly beans faworki. Sugar plum wafer faworki marshmallow brownie ice cream cotton candy marshmallow marzipan. Cheesecake gummi bears cupcake sweet croissant cookie chocolate bar sweet roll. Halvah cupcake carrot cake souffle carrot cake chocolate cake pastry gummi bears muffin. Sweet roll candy gingerbread dessert tart. Pastry oat cake jelly beans.'
    );
    append(container, text);
    append(BODY, container);
    await sleep(1);
    await snapshot();
    container.scrollTo(0, 100);
    await snapshot();
  });

  it('scroll', async () => {
    let container = createElementWithStyle('div', {
      'background-attachment': 'local',
      backgroundRepeat: 'no-repeat',
      'background-image':
        'url(https://kraken.oss-cn-hangzhou.aliyuncs.com/images/cat.png)',
      'background-color': 'yellow',
      border: '10px solid rgba(0, 0, 0, 0.3)',
      height: '250px',
      width: '250px',
      overflow: 'scroll',
    });
    let text = createText(`Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text Filler Text
        Filler Text Filler Text`);
    append(container, text);
    append(BODY, container);
    await sleep(1);
    await snapshot(container);
  });
});
