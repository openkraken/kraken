/*auto generated*/
describe('columns-auto', () => {
  it("size 001", async () => {
    let log;
    let flexbox;
    let flexbox_1;
    let flexbox_2;
    let flexbox_3;
    let flexbox_4;
    let flexbox_5;
    let flexbox_6;
    let flexbox_8;
    log = createElement("div", {
      id: "log",
      style: {
        "box-sizing": "border-box",
      },
    });
    flexbox = createElement(
      "div",
      {
        class: "flexbox column horizontal",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "background-color": "#aaa",
          position: "relative",
          width: "400px",
          "box-sizing": "border-box",
        },
      },
      [
        createElement("div", {
          "data-expected-height": "10",
          "data-offset-y": "0",
          style: {
            width: "100%",
            "background-color": "blue",
            "box-sizing": "border-box",
            flex: "1 0 10px",
          },
        }),
        createElement("div", {
          "data-expected-height": "10",
          "data-offset-y": "10",
          style: {
            width: "100%",
            "background-color": "green",
            "box-sizing": "border-box",
            height: "10px",
          },
        }),
        createElement(
          "div",
          {
            "data-expected-height": "10",
            "data-offset-y": "20",
            style: {
              width: "100%",
              "background-color": "red",
              "box-sizing": "border-box",
            },
          },
          [
            createElement("div", {
              "data-expected-height": "10",
              "data-offset-y": "20",
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
      ]
    );
    flexbox_1 = createElement(
      "div",
      {
        class: "flexbox column horizontal",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "background-color": "#aaa",
          position: "relative",
          width: "400px",
          "box-sizing": "border-box",
        },
      },
      [
        createElement("div", {
          "data-expected-height": "0",
          "data-offset-y": "0",
          style: {
            width: "100%",
            "background-color": "blue",
            "box-sizing": "border-box",
            flex: "1",
          },
        }),
        createElement("div", {
          "data-expected-height": "10",
          "data-offset-y": "0",
          style: {
            width: "100%",
            "background-color": "green",
            "box-sizing": "border-box",
            height: "10px",
          },
        }),
        createElement(
          "div",
          {
            "data-expected-height": "10",
            "data-offset-y": "10",
            style: {
              width: "100%",
              "background-color": "red",
              "box-sizing": "border-box",
              flex: "1 auto",
            },
          },
          [
            createElement("div", {
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
        createElement(
          "div",
          {
            "data-expected-height": "10",
            "data-offset-y": "20",
            style: {
              width: "100%",
              "background-color": "orange",
              "box-sizing": "border-box",
              "min-height": "0",
              flex: "1",
            },
          },
          [
            (childDiv = createElement("div", {
              "data-expected-height": "10",
              "data-offset-y": "20",
              class: "child-div",
              style: {
                width: "100%",
                "background-color": "yellow",
                "box-sizing": "border-box",
                height: "10px",
              },
            })),
          ]
        ),
      ]
    );
    flexbox_2 = createElement(
      "div",
      {
        class: "flexbox column horizontal",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "background-color": "#aaa",
          position: "relative",
          width: "400px",
          "box-sizing": "border-box",
        },
      },
      [
        createElement("div", {
          "data-expected-height": "10",
          "data-offset-y": "10",
          style: {
            width: "100%",
            "background-color": "blue",
            "box-sizing": "border-box",
            flex: "1 0 10px",
            "margin-top": "10px",
          },
        }),
        createElement("div", {
          "data-expected-height": "10",
          "data-offset-y": "20",
          style: {
            width: "100%",
            "background-color": "green",
            "box-sizing": "border-box",
            height: "10px",
            "margin-bottom": "20px",
          },
        }),
        createElement(
          "div",
          {
            "data-expected-height": "20",
            "data-offset-y": "50",
            style: {
              width: "100%",
              "background-color": "red",
              "box-sizing": "border-box",
              "padding-top": "10px",
            },
          },
          [
            createElement("div", {
              "data-expected-height": "10",
              "data-offset-y": "60",
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
      ]
    );
    flexbox_3 = createElement(
      "div",
      {
        class: "flexbox column horizontal justify-content-space-between",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "-webkit-justify-content": "space-between",
          "justify-content": "space-between",
          "background-color": "#aaa",
          position: "relative",
          width: "400px",
          "box-sizing": "border-box",
        },
      },
      [
        createElement("div", {
          "data-expected-height": "10",
          "data-offset-y": "10",
          style: {
            width: "100%",
            "background-color": "blue",
            "box-sizing": "border-box",
            flex: "1 0 10px",
            "margin-top": "10px",
          },
        }),
        createElement("div", {
          "data-expected-height": "10",
          "data-offset-y": "20",
          style: {
            width: "100%",
            "background-color": "green",
            "box-sizing": "border-box",
            height: "10px",
            "margin-bottom": "20px",
          },
        }),
        createElement(
          "div",
          {
            "data-expected-height": "20",
            "data-offset-y": "50",
            style: {
              width: "100%",
              "background-color": "red",
              "box-sizing": "border-box",
              "padding-top": "10px",
            },
          },
          [
            createElement("div", {
              "data-expected-height": "10",
              "data-offset-y": "60",
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
      ]
    );
    flexbox_4 = createElement(
      "div",
      {
        class: "flexbox column horizontal",
        "data-expected-height": "20",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "background-color": "#aaa",
          position: "relative",
          width: "400px",
          "box-sizing": "border-box",
        },
      },
      [
        createElement(
          "div",
          {
            "data-expected-height": "10",
            "data-offset-y": "0",
            style: {
              width: "100%",
              "background-color": "blue",
              "box-sizing": "border-box",
              flex: "0 1 auto",
            },
          },
          [
            createElement("div", {
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
        createElement(
          "div",
          {
            "data-expected-height": "10",
            "data-offset-y": "10",
            style: {
              width: "100%",
              "background-color": "green",
              "box-sizing": "border-box",
              flex: "0 2 auto",
            },
          },
          [
            createElement("div", {
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
      ]
    );
    flexbox_5 = createElement(
      "div",
      {
        class: "flexbox column horizontal",
        "data-expected-height": "20",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "background-color": "#aaa",
          position: "relative",
          width: "400px",
          "box-sizing": "border-box",
          "min-height": "10px",
        },
      },
      [
        createElement(
          "div",
          {
            "data-expected-height": "10",
            "data-offset-y": "0",
            style: {
              width: "100%",
              "background-color": "blue",
              "box-sizing": "border-box",
              flex: "0 1 auto",
            },
          },
          [
            createElement("div", {
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
        createElement(
          "div",
          {
            "data-expected-height": "10",
            "data-offset-y": "10",
            style: {
              width: "100%",
              "background-color": "green",
              "box-sizing": "border-box",
              flex: "0 2 auto",
            },
          },
          [
            createElement("div", {
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
      ]
    );
    flexbox_6 = createElement(
      "div",
      {
        class: "flexbox column horizontal",
        "data-expected-height": "17",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "background-color": "#aaa",
          position: "relative",
          width: "400px",
          "box-sizing": "border-box",
          "min-height": "5px",
          "max-height": "17px",
        },
      },
      [
        createElement(
          "div",
          {
            "data-expected-height": "9",
            "data-offset-y": "0",
            style: {
              width: "100%",
              "background-color": "blue",
              "box-sizing": "border-box",
              "min-height": "0",
              flex: "0 1 auto",
            },
          },
          [
            createElement("div", {
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
        createElement(
          "div",
          {
            "data-expected-height": "8",
            "data-offset-y": "9",
            style: {
              width: "100%",
              "background-color": "green",
              "box-sizing": "border-box",
              "min-height": "0",
              flex: "0 2 auto",
            },
          },
          [
            createElement("div", {
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
      ]
    );
    flexbox_8 = createElement(
      "div",
      {
        class: "flexbox column horizontal",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "background-color": "#aaa",
          position: "relative",
          width: "400px",
          "box-sizing": "border-box",
        },
      },
      [
        createElement(
          "div",
          {
            "data-expected-client-height": "10",
            "data-offset-y": "0",
            style: {
              width: "100%",
              "background-color": "blue",
              "box-sizing": "border-box",
              overflow: "scroll",
            },
          },
          [
            createElement("div", {
              "data-expected-height": "10",
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "10px",
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flexbox);
    BODY.appendChild(flexbox_1);
    BODY.appendChild(flexbox_2);
    BODY.appendChild(flexbox_3);
    BODY.appendChild(flexbox_4);
    BODY.appendChild(flexbox_5);
    BODY.appendChild(flexbox_6);
    BODY.appendChild(flexbox_8);

    await snapshot();
  });

  // @TODO: max-width/max-height is not considered when calculating remaining space for flex-shrink.
  xit("size 002", async () => {
    let flexbox_7;
    flexbox_7 = createElement(
      "div",
      {
        class: "flexbox column horizontal",
        "data-expected-height": "33",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "background-color": "#aaa",
          position: "relative",
          width: "400px",
          "box-sizing": "border-box",
          "min-height": "5px",
          "max-height": "30px",
          "padding-top": "1px",
          "padding-bottom": "2px",
        },
      },
      [
        createElement(
          "div",
          {
            "data-expected-height": "15",
            "data-offset-y": "1",
            style: {
              width: "100%",
              "background-color": "blue",
              "box-sizing": "border-box",
              "min-height": "0",
              flex: "0 1 auto",
            },
          },
          [
            createElement("div", {
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "20px",
              },
            }),
          ]
        ),
        createElement(
          "div",
          {
            "data-expected-height": "15",
            "data-offset-y": "16",
            style: {
              width: "100%",
              "background-color": "green",
              "box-sizing": "border-box",
              "min-height": "0",
              flex: "0 1 auto",
            },
          },
          [
            createElement("div", {
              style: {
                width: "100%",
                "box-sizing": "border-box",
                height: "20px",
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(flexbox_7);

    await snapshot();
  });

  // @TODO: Percentage size of child should not be considered in auto min content width/height.
  xit("size 003", async () => {
    let flexbox_9;
    flexbox_9 = createElement(
      "div",
      {
        class: "flexbox column vertical",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "background-color": "#aaa",
          position: "relative",
          height: "50px",
          "box-sizing": "border-box",
        },
      },
      [
        createElement("div", {
          "data-expected-width": "10",
          "data-offset-x": "20",
          style: {
            height: "100%",
            "background-color": "blue",
            "box-sizing": "border-box",
            flex: "1 0 10px",
          },
        }),
        createElement("div", {
          "data-expected-width": "10",
          "data-offset-x": "10",
          style: {
            height: "100%",
            "background-color": "green",
            "box-sizing": "border-box",
            width: "10px",
          },
        }),
        createElement(
          "div",
          {
            "data-expected-width": "10",
            "data-offset-x": "0",
            style: {
              height: "100%",
              "background-color": "red",
              "box-sizing": "border-box",
            },
          },
          [
            createElement("div", {
              "data-expected-width": "10",
              "data-offset-x": "0",
              style: {
                height: "100%",
                "box-sizing": "border-box",
                width: "10px",
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(flexbox_9);

    await snapshot();
  });

  // @TODO: Percentage size of child should not be considered in auto min content width/height.
  xit("size 004", async () => {
    let flexbox_10;
    let childDiv;
    let childDiv_1;
    flexbox_10 = createElement(
      "div",
      {
        class: "flexbox column vertical",
        style: {
          display: "flex",
          "-webkit-flex-direction": "column",
          "flex-direction": "column",
          "background-color": "#aaa",
          position: "relative",
          height: "50px",
          "box-sizing": "border-box",
          "margin-left": "100px",
        },
      },
      [
        createElement(
          "div",
          {
            "data-expected-width": "50",
            "data-offset-x": "20",
            style: {
              height: "100%",
              "background-color": "blue",
              "box-sizing": "border-box",
              "min-width": "0",
              flex: "1",
            },
          },
          [
            (childDiv_1 = createElement("div", {
              "data-expected-width": "50",
              "data-offset-x": "20",
              class: "child-div",
              style: {
                height: "100%",
                "background-color": "yellow",
                "box-sizing": "border-box",
                width: "50px",
              },
            })),
          ]
        ),
        createElement("div", {
          "data-expected-width": "0",
          "data-offset-x": "20",
          style: {
            height: "100%",
            "background-color": "green",
            "box-sizing": "border-box",
            flex: "1",
          },
        }),
        createElement("div", {
          "data-expected-width": "10",
          "data-offset-x": "10",
          style: {
            height: "100%",
            "background-color": "red",
            "box-sizing": "border-box",
            width: "10px",
          },
        }),
        createElement(
          "div",
          {
            "data-expected-width": "10",
            "data-offset-x": "0",
            style: {
              height: "100%",
              "background-color": "orange",
              "box-sizing": "border-box",
              flex: "1 auto",
            },
          },
          [
            createElement("div", {
              style: {
                height: "100%",
                "box-sizing": "border-box",
                width: "10px",
              },
            }),
          ]
        ),
      ]
    );
    BODY.appendChild(flexbox_10);

    await snapshot();
  });
});
