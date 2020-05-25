describe('Transform origin', () => {
  it('transform origin works width margin' , async (done) => {
    let n1, n2;
    n1 = createElementWithStyle(
       'div',
       {
         display: 'flex',
         flexDirection: 'column',
         justifyContent: 'center',
         alignItems: 'center',
         width: '300px',
         height: '300px',
         backgroundColor: 'gray',
       },
       [
        (n2 = createElementWithStyle(
          'div',
           {
             position: 'relative',
             width: '100px',
             height: '100px',
             backgroundColor: 'blue',
             marginRight: '100px',
             transform: 'scale(1.5)'
           },
        ))
       ]
     );
    BODY.appendChild(n1);

    await matchScreenshot();
  });
});
