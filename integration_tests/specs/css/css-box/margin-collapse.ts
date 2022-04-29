describe("Margin collapse", () => {
  describe("margin-top collapse with parent", () => {
    it("should work with margin-top collapse with parent", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            height: "100px",
            backgroundColor: "grey",
            margin: "50px 0 70px"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            [
              createElement("div", {
                style: {
                  width: "200px",
                  height: "25px",
                  backgroundColor: "lightblue",
                  margin: "90px 0"
                }
              })
            ]
          )
        ]
      );

      BODY.appendChild(div1);

      await snapshot();
    });

    it("should work with negative margin-top collapse with parent", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            height: "100px",
            backgroundColor: "grey",
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "-50px 0"
              }
            },
          )
        ]
      );

      BODY.appendChild(div1);

      await snapshot();
    });

    it("should not work with element of display inline-block", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            display: "inline-block",
            width: "300px",
            height: "100px",
            backgroundColor: "grey",
            margin: "50px 0 70px"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            [
              createElement("div", {
                style: {
                  width: "200px",
                  height: "25px",
                  backgroundColor: "lightblue",
                  margin: "90px 0"
                }
              })
            ]
          )
        ]
      );

      BODY.appendChild(div1);

      await snapshot();
    });

    it("should not work with element of display flex", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",

            width: "300px",
            height: "100px",
            backgroundColor: "grey",
            margin: "50px 0 70px"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                display: 'flex',
                flexDirection: 'column',
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            [
              createElement("div", {
                style: {
                  width: "200px",
                  height: "25px",
                  backgroundColor: "lightblue",
                  margin: "90px 0"
                }
              })
            ]
          )
        ]
      );

      BODY.appendChild(div1);

      await snapshot();
    });
    
    it("should not work with element of overflow scroll", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            overflow: 'scroll',
            width: "300px",
            height: "100px",
            backgroundColor: "grey",
            margin: "50px 0 70px"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            [
              createElement("div", {
                style: {
                  width: "200px",
                  height: "25px",
                  backgroundColor: "lightblue",
                  margin: "90px 0"
                }
              })
            ]
          )
        ]
      );

      BODY.appendChild(div1);

      await snapshot();
    });

    it("should not work with element of position absolute", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "absolute",
            overflow: 'scroll',
            width: "300px",
            height: "100px",
            backgroundColor: "grey",
            margin: "50px 0 70px"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            [
              createElement("div", {
                style: {
                  width: "200px",
                  height: "25px",
                  backgroundColor: "lightblue",
                  margin: "90px 0"
                }
              })
            ]
          )
        ]
      );

      BODY.appendChild(div1);

      await snapshot();
    });
  });

  describe("margin-bottom collapse with parent", () => {
    it("should work with margin-bottom collapse with parent when parent has no height", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            [
              createElement("div", {
                style: {
                  width: "200px",
                  height: "50px",
                  backgroundColor: "lightblue",
                  margin: "100px 0"
                }
              })
            ]
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should not work with margin-bottom collapse with parent when parent has height", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            []
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should work with negative margin-bottom collapse with parent", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            backgroundColor: "grey",
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                marginBottom: "-80px"
              }
            },
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should not work with element of display inline-block", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            display: 'inline-block',
            width: "300px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            [
              createElement("div", {
                style: {
                  width: "200px",
                  height: "50px",
                  backgroundColor: "lightblue",
                  margin: "100px 0"
                }
              })
            ]
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should not work with element of display flex", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            display: 'flex',
            flexDirection: 'column',
            width: "300px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            [
              createElement("div", {
                style: {
                  width: "200px",
                  height: "50px",
                  backgroundColor: "lightblue",
                  margin: "100px 0"
                }
              })
            ]
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should not work with element of overflow scroll", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            overflow: 'scroll',
            width: "300px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            [
              createElement("div", {
                style: {
                  width: "200px",
                  height: "50px",
                  backgroundColor: "lightblue",
                  margin: "100px 0"
                }
              })
            ]
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should not work with element of position absolute", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "absolute",
            width: "300px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            [
              createElement("div", {
                style: {
                  width: "200px",
                  height: "50px",
                  backgroundColor: "lightblue",
                  margin: "100px 0"
                }
              })
            ]
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });
  });

  describe("margin collapse with previous sibling", () => {
    it("should work with margin-top collapse with the margin-bottom of previous sibling when margin-top is smaller than previous margin-bottom", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            []
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral",
            margin: "40px 0"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should work with margin-top collapse with the margin-bottom of previous sibling when margin-top is larger than previous margin-bottom", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            []
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral",
            margin: "100px 0"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should work with negative margin-top collapse with the previous sibling", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "grey",
          }
        },
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral",
            marginTop: "-150px"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should not work with element of display inline-block", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            display: 'inline-block',
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            []
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral",
            margin: "40px 0"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should not work with element of display flex", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            display: 'flex',
            flexDirection: 'column',
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            []
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral",
            margin: "40px 0"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should not work with element of overflow scroll", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            overflow: 'scroll',
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            []
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral",
            margin: "40px 0"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });

    it("should not work with element of position absolute", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "absolute",
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        [
          createElement(
            "div",
            {
              style: {
                width: "250px",
                height: "50px",
                backgroundColor: "lightgreen",
                margin: "80px 0"
              }
            },
            []
          )
        ]
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral",
            margin: "40px 0"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);

      await snapshot();
    });
  });

  describe("margin collapse with empty block", () => {
    it("should work with margin-top and margin-bottom collapse of empty block", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        []
      );

      let div2 = createElement(
        "div",
        {
          style: {
            width: "300px",
            backgroundColor: "coral",
            margin: "100px 0"
          }
        },
        []
      );
      let div3 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);
      BODY.appendChild(div3);

      await snapshot();
    });

    it("should not work with element of display inline-block", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        []
      );

      let div2 = createElement(
        "div",
        {
          style: {
            display: 'inline-block',
            width: "300px",
            backgroundColor: "coral",
            margin: "100px 0"
          }
        },
        []
      );
      let div3 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);
      BODY.appendChild(div3);

      await snapshot();
    });

    it("should not work with element of display flex", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        []
      );

      let div2 = createElement(
        "div",
        {
          style: {
            display: 'flex',
            width: "300px",
            backgroundColor: "coral",
            margin: "100px 0"
          }
        },
        []
      );
      let div3 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);
      BODY.appendChild(div3);

      await snapshot();
    });

    it("should not work with element of overflow scroll", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        []
      );

      let div2 = createElement(
        "div",
        {
          style: {
            overflow: 'scroll',
            width: "300px",
            backgroundColor: "coral",
            margin: "100px 0"
          }
        },
        []
      );
      let div3 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);
      BODY.appendChild(div3);

      await snapshot();
    });

    it("should not work with element of position absolute", async () => {
      let div1 = createElement(
        "div",
        {
          style: {
            position: "relative",
            width: "300px",
            height: "50px",
            backgroundColor: "grey",
            margin: "50px 0"
          }
        },
        []
      );

      let div2 = createElement(
        "div",
        {
          style: {
            position: 'absolute',
            width: "300px",
            backgroundColor: "coral",
            margin: "100px 0"
          }
        },
        []
      );
      let div3 = createElement(
        "div",
        {
          style: {
            width: "300px",
            height: "100px",
            backgroundColor: "coral"
          }
        },
        []
      );

      BODY.appendChild(div1);
      BODY.appendChild(div2);
      BODY.appendChild(div3);

      await snapshot();
    });
  });

  it('should work with empty block and margin top with parent collapse', async () => {
    let div1;
    let div2;
    div1 = createElement(
      'div',
      {
        style: {
          margin: '0 0 20px',
        },
      },
    );
    div2 = createElement(
      'div',
      {
        style: {
          width: '200px',
          height: '50px',
          background: 'green',
          color: 'white',
        },
      },
    );

    BODY.appendChild(div1);
    BODY.appendChild(div2);

    await snapshot();
  });
});
