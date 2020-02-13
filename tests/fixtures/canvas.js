__kraken_ui_manager__(
  JSON.stringify([
    "createElement",
    [
      {
        type: "DIV",
        id: 1,
        props: {
          style: { width: "300px", height: "300px", backgroundColor: "#eee" }
        }
      }
    ]
  ])
);

__kraken_ui_manager__(
  JSON.stringify([
    "createElement",
    [
      {
        type: "CANVAS",
        id: 2,
        props: {
          style: { width: "200px", height: "200px" }
        }
      }
    ]
  ])
);

setTimeout(() => {
  var _ctx = __kraken_ui_manager__(
    JSON.stringify([
      'method',
      [
        2,
        'getContext',
        ['2d']
      ]
    ])
  );
  var context = JSON.parse(_ctx);

//    context.fillStyle = WebColor.green;
  __kraken_ui_manager__(
    JSON.stringify([
      'method',
      [
        2,
        'updateContext2DProperty',
        ['fillStyle', 'green']
      ]
    ])
  );
  //  context.fillRect(10, 10, 50, 50);
  __kraken_ui_manager__(
    JSON.stringify([
      'method',
      [
        2,
        'applyContext2DMethod',
        ['fillRect', 10, 10, 50, 50]
      ]
    ])
  );
  // context.clearRect(15, 15, 30, 30);
  __kraken_ui_manager__(
    JSON.stringify([
      'method',
      [
        2,
        'applyContext2DMethod',
        ['clearRect', 15, 15, 30, 30]
      ]
    ])
  );
//    context.strokeStyle = WebColor.red;
  __kraken_ui_manager__(
    JSON.stringify([
      'method',
      [
        2,
        'updateContext2DProperty',
        ['strokeStyle', 'red']
      ]
    ])
  );
//    context.strokeRect(40, 40, 100, 100);
  __kraken_ui_manager__(
    JSON.stringify([
      'method',
      [
        2,
        'applyContext2DMethod',
        ['strokeRect', 40, 40, 100, 100]
      ]
    ])
  );
//    context.fillStyle = WebColor.blue;
  __kraken_ui_manager__(
    JSON.stringify([
      'method',
      [
        2,
        'updateContext2DProperty',
        ['fillStyle', 'blue']
      ]
    ])
  );
//    context.fillText('Hello World', 5.0, 5.0);
  __kraken_ui_manager__(
    JSON.stringify([
      'method',
      [
        2,
        'applyContext2DMethod',
        ['fillText', 'Hello World', 5.0, 5.0]
      ]
    ])
  );
//    context.strokeText('Hello World', 5.0, 25.0);
  __kraken_ui_manager__(
    JSON.stringify([
      'method',
      [
        2,
        'applyContext2DMethod',
        ['strokeText', 'Hello World', 5.0, 25.0]
      ]
    ])
  );

}, 500);


__kraken_ui_manager__(
  JSON.stringify(["insertAdjacentNode", [1, "beforeend", 2]])
);

__kraken_ui_manager__(
  JSON.stringify(["insertAdjacentNode", [-1, "beforeend", 1]])
);

