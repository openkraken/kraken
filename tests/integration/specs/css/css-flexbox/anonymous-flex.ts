// /*auto generated*/
// describe('anonymous-flex', () => {
//   it('item-001', async () => {
//     let p;
//     let div;
//     p = createElement(
//       'p',
//       {
//         style: {
//           'box-sizing': 'border-box',
//         },
//       },
//       [createText(`There should be a space between "two" and "words" below.`)]
//     );
//     div = createElement(
//       'div',
//       {
//         style: {
//           'box-sizing': 'border-box',
//           display: 'flex',
//         },
//       },
//       [createText(`two words`)]
//     );
//     BODY.appendChild(p);
//     BODY.appendChild(div);

//     document.body.offsetTop;
//     spanRemove.remove();

//     await matchScreenshot();
//   });
//   it('item-002', async () => {
//     let p;
//     let div;
//     p = createElement(
//       'p',
//       {
//         style: {
//           'box-sizing': 'border-box',
//         },
//       },
//       [createText(`There should be a space between "two" and "words" below.`)]
//     );
//     div = createElement(
//       'div',
//       {
//         style: {
//           'box-sizing': 'border-box',
//           display: 'flex',
//         },
//       },
//       [
//         createText(`two `),
//         createElement('span', {
//           style: {
//             'box-sizing': 'border-box',
//             display: 'none',
//           },
//         }),
//         createText(`words`),
//       ]
//     );
//     BODY.appendChild(p);
//     BODY.appendChild(div);

//     await matchScreenshot();
//   });
//   it('item-003', async () => {
//     let p;
//     let noneSpan;
//     let div;
//     p = createElement(
//       'p',
//       {
//         style: {
//           'box-sizing': 'border-box',
//         },
//       },
//       [createText(`There should be a space between "two" and "words" below.`)]
//     );
//     div = createElement(
//       'div',
//       {
//         style: {
//           'box-sizing': 'border-box',
//           display: 'flex',
//         },
//       },
//       [
//         createText(`two `),
//         (noneSpan = createElement('span', {
//           style: {
//             'box-sizing': 'border-box',
//             display: 'none',
//           },
//         })),
//         createText(`words`),
//       ]
//     );
//     BODY.appendChild(p);
//     BODY.appendChild(div);

//     document.body.offsetTop;
//     noneSpan.style.display = 'none';

//     await matchScreenshot();
//   });
//   it('item-004', async () => {
//     let p;
//     let div;
//     p = createElement(
//       'p',
//       {
//         style: {
//           'box-sizing': 'border-box',
//         },
//       },
//       [
//         createText(
//           `The words "Two" and "lines" should not be on the same line.`
//         ),
//       ]
//     );
//     div = createElement(
//       'div',
//       {
//         style: {
//           'box-sizing': 'border-box',
//           display: 'flex',
//           'flex-direction': 'column',
//         },
//       },
//       [
//         createText(`Two `),
//         createElement('span', {
//           style: {
//             'box-sizing': 'border-box',
//             position: 'absolute',
//           },
//         }),
//         createText(`lines`),
//       ]
//     );
//     BODY.appendChild(p);
//     BODY.appendChild(div);

//     await matchScreenshot();
//   });
//   it('item-005', async () => {
//     let p;
//     let absSpan;
//     let div;
//     p = createElement(
//       'p',
//       {
//         style: {
//           'box-sizing': 'border-box',
//         },
//       },
//       [
//         createText(
//           `The words "Two" and "lines" should not be on the same line.`
//         ),
//       ]
//     );
//     div = createElement(
//       'div',
//       {
//         style: {
//           'box-sizing': 'border-box',
//           display: 'flex',
//           'flex-direction': 'column',
//         },
//       },
//       [
//         createText(`Two`),
//         (absSpan = createElement('span', {
//           style: {
//             'box-sizing': 'border-box',
//           },
//         })),
//         createText(`lines`),
//       ]
//     );
//     BODY.appendChild(p);
//     BODY.appendChild(div);

//     await matchScreenshot();

//     absSpan.style.display = 'none';
//     absSpan.style.position = 'absolute';
//     absSpan.style.display = 'inline';

//     await matchScreenshot();
//   });
// });
