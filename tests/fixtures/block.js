__kraken_ui_manager__(
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
__kraken_ui_manager__(
  JSON.stringify(["insertAdjacentNode", [-1, "beforeend", 1]])
);
