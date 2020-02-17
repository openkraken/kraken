__kraken_ui_manager__(
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
__kraken_ui_manager__(
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
__kraken_ui_manager__(
  JSON.stringify(["insertAdjacentNode", [1, "beforeend", 2]])
);
__kraken_ui_manager__(
  JSON.stringify(["insertAdjacentNode", [-1, "beforeend", 1]])
);
__kraken_ui_manager__(
  JSON.stringify(["setProperty",[1,"style",{"fontSize":"80px"}]])
);
__kraken_ui_manager__(
  JSON.stringify(["setProperty",[1,"style",{"fontSize":"80px","textDecoration":"line-through"}]])
);
