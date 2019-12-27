__kraken_js_to_dart__(
  JSON.stringify([
    "createElement",
    [
      {
        type: "DIV",
        id: 1,
        props: {
          style: { width: "300px", height: "300px", backgroundColor: "red" }
        }
      }
    ]
  ])
);

__kraken_js_to_dart__(
  JSON.stringify([
    "createElement",
    [
      {
        type: "DIV",
        id: 2,
        props: {
          style: { width: "150px", height: "150px", backgroundColor: "green" }
        }
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
