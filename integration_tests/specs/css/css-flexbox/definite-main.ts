/*auto generated*/
describe('definite-main', () => {
  it("size 001", async () => {
    let p;
    let flexbox;
    let rect;
    let rect_1;
    let rect_2;
    let rect_3;
    let rect_4;
    let rect_5;
    let rect_6;
    let rect_7;
    p = createElement(
      "p",
      {
        style: {
          "box-sizing": "border-box",
        },
      },
      [createText(`Simple case of percentage resolution:`)]
    );
    flexbox = createElement(
      "div",
      {
        class: "flexbox",
        style: {
          display: "flex",
          border: "3px solid black",
          "box-sizing": "border-box",
          width: "300px",
        },
      },
      [
        (flexOne = createElement(
          "div",
          {
            class: "flex-one",
            "data-expected-width": "250",
            style: {
              "-webkit-flex": "1",
              flex: "1",
              "box-sizing": "border-box",
            },
          },
          [
            createElement(
              "div",
              {
                "data-expected-width": "125",
                style: {
                  overflow: "hidden",
                  "box-sizing": "border-box",
                  width: "50%",
                },
              },
              [
                (rect = createElement("div", {
                  class: "rect",
                  style: {
                    width: "50px",
                    height: "50px",
                    "background-color": "green",
                    "box-sizing": "border-box",
                  },
                })),
              ]
            ),
          ]
        )),
        (rect_1 = createElement("div", {
          class: "rect flex-none",
          style: {
            "-webkit-flex": "none",
            flex: "none",
            width: "50px",
            height: "50px",
            "background-color": "green",
            "box-sizing": "border-box",
          },
        })),
      ]
    );
  
    BODY.appendChild(p);
    BODY.appendChild(flexbox);
  
    await snapshot();
  });
  
  // @TODO: The width of parent with no width style is no determined by its child but its grand child?
  xit("size 002", async () => {
    let p_1;
    let flexbox_1;
    let rect;
    let rect_1;
    let rect_2;
    let rect_3;
    let rect_4;
    let rect_5;
    let rect_6;
    let rect_7;
    p_1 = createElement(
      "p",
      {
        style: {
          "box-sizing": "border-box",
        },
      },
      [
        createText(`auto flex-basis. However, as this is a width, we follow regular width
      rules and resolve the percentage:`),
      ]
    );
    flexbox_1 = createElement(
      "div",
      {
        class: "flexbox",
        style: {
          display: "flex",
          border: "3px solid black",
          "box-sizing": "border-box",
          width: "300px",
        },
      },
      [
        createElement(
          "div",
          {
            "data-expected-width": "50",
            style: {
              "box-sizing": "border-box",
            },
          },
          [
            createElement(
              "div",
              {
                "data-expected-width": "25",
                style: {
                  overflow: "hidden",
                  "box-sizing": "border-box",
                  width: "50%",
                },
              },
              [
                (rect_2 = createElement("div", {
                  class: "rect",
                  style: {
                    width: "50px",
                    height: "50px",
                    "background-color": "green",
                    "box-sizing": "border-box",
                  },
                })),
              ]
            ),
          ]
        ),
        (rect_3 = createElement("div", {
          class: "rect flex-none",
          style: {
            "-webkit-flex": "none",
            flex: "none",
            width: "50px",
            height: "50px",
            "background-color": "green",
            "box-sizing": "border-box",
          },
        })),
      ]
    );
    BODY.appendChild(p_1);
    BODY.appendChild(flexbox_1);
  
    await snapshot();
  });
  
  it("size 003", async () => {
    let p_2;
    let flexbox_2;
    let rect;
    let rect_1;
    let rect_2;
    let rect_3;
    let rect_4;
    let rect_5;
    let rect_6;
    let rect_7;
    p_2 = createElement(
      "p",
      {
        style: {
          "box-sizing": "border-box",
        },
      },
      [createText(`Simple case of percentage resolution, columns:`)]
    );
    flexbox_2 = createElement(
      "div",
      {
        class: "flexbox column",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          border: "3px solid black",
          "box-sizing": "border-box",
          height: "300px",
        },
      },
      [
        (flexOne_1 = createElement(
          "div",
          {
            class: "flex-one",
            "data-expected-height": "250",
            style: {
              "-webkit-flex": "1",
              flex: "1",
              "box-sizing": "border-box",
            },
          },
          [
            createElement(
              "div",
              {
                "data-expected-height": "125",
                style: {
                  overflow: "hidden",
                  "box-sizing": "border-box",
                  height: "50%",
                },
              },
              [
                (rect_4 = createElement("div", {
                  class: "rect",
                  style: {
                    width: "50px",
                    height: "50px",
                    "background-color": "green",
                    "box-sizing": "border-box",
                  },
                })),
              ]
            ),
          ]
        )),
        (rect_5 = createElement("div", {
          class: "rect flex-none",
          style: {
            "-webkit-flex": "none",
            flex: "none",
            width: "50px",
            height: "50px",
            "background-color": "green",
            "box-sizing": "border-box",
          },
        })),
      ]
    );
    BODY.appendChild(p_2);
    BODY.appendChild(flexbox_2);
  
    await snapshot();
  });
  
  // @TODO: The height of parent with no height style is no determined by its child but its grand child?
  xit("size 004", async () => {
    let p_3;
    let flexbox_3;
    let rect;
    let rect_1;
    let rect_2;
    let rect_3;
    let rect_4;
    let rect_5;
    let rect_6;
    let rect_7;
    p_3 = createElement(
      "p",
      {
        style: {
          "box-sizing": "border-box",
        },
      },
      [createText(`auto flex-basis. This is still definite.`)]
    );
    flexbox_3 = createElement(
      "div",
      {
        class: "flexbox column",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          border: "3px solid black",
          "box-sizing": "border-box",
          height: "300px",
        },
      },
      [
        createElement(
          "div",
          {
            "data-expected-height": "50",
            style: {
              "box-sizing": "border-box",
            },
          },
          [
            createElement(
              "div",
              {
                "data-expected-height": "25",
                style: {
                  overflow: "hidden",
                  "box-sizing": "border-box",
                  height: "50%",
                },
              },
              [
                (rect_6 = createElement("div", {
                  class: "rect",
                  style: {
                    width: "50px",
                    height: "50px",
                    "background-color": "green",
                    "box-sizing": "border-box",
                  },
                })),
              ]
            ),
          ]
        ),
        (rect_7 = createElement("div", {
          class: "rect flex-none",
          style: {
            "-webkit-flex": "none",
            flex: "none",
            width: "50px",
            height: "50px",
            "background-color": "green",
            "box-sizing": "border-box",
          },
        })),
      ]
    );
    BODY.appendChild(p_3);
    BODY.appendChild(flexbox_3);
  
    await snapshot();
  });
});
