__kraken_js_to_dart__(
    JSON.stringify([
      "createElement",
      [
        {
          type: "DIV",
          id: 1,
          props: {
            style: { margin: "20rpx 30rpx 30rpx 30rpx",
             backgroundColor: "blue" }
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
            style: { width: "10px", height: "10px"}
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
          id: 3,
          props: {
            style: { width: "200px", height: "200px",
             backgroundImage: "radial-gradient(50%, red 0%, yellow 20%, blue 80%)" }
          }
        }
      ]
    ])
  );
  
  __kraken_js_to_dart__(
    JSON.stringify(["insertAdjacentNode", [-1, "beforeend", 1]])
  );
  __kraken_js_to_dart__(
    JSON.stringify(["insertAdjacentNode", [1, "beforeend", 2]])
  );
  __kraken_js_to_dart__(
    JSON.stringify(["insertAdjacentNode", [-1, "beforeend", 3]])
  );