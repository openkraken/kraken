__kraken_js_to_dart__(
  JSON.stringify([
    "createElement",
    [
      {
        type: "SPAN",
        id: 1,
        props: {}
      }
    ]
  ])
);
__kraken_js_to_dart__(
  JSON.stringify([
    "createTextNode",
    [
      {
        id: 2,
        nodeType: 3,
        data: 'hello world',
      }
    ]
  ])
);
__kraken_js_to_dart__(
  JSON.stringify(["insertAdjacentNode", [1, "beforeend", 2]])
);
__kraken_js_to_dart__(
  JSON.stringify(["insertAdjacentNode", [-1, "beforeend", 1]])
);
