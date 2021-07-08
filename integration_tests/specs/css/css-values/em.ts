describe("em", () => {
  it("should works with style of font size", async () => {
    let div;
    let div2;
    let div3;
    div = createElement(
      "div",
      {
        style: {
          position: "relative",
          width: "200px",
          height: "200px",
          backgroundColor: "green"
        }
      },
      [
        (div2 = createElement(
          "div",
          {
            style: {
              width: "150px",
              height: "150px",
              backgroundColor: "yellow"
            }
          },
          [
            (div3 = createElement(
              "div",
              {
                style: {
                  fontSize: "2em",
                  width: "100px",
                  height: "100px",
                  backgroundColor: "blue"
                }
              },
              [createText("font-size")]
            ))
          ]
        ))
      ]
    );

    BODY.appendChild(div);

    await snapshot();
  });

  it("should works with style other than font size", async () => {
    let div;
    let div2;
    let div3;
    div = createElement(
      "div",
      {
        style: {
          position: "relative",
          width: "200px",
          height: "200px",
          backgroundColor: "green"
        }
      },
      [
        (div2 = createElement(
          "div",
          {
            style: {
              width: "150px",
              height: "150px",
              backgroundColor: "yellow"
            }
          },
          [
            (div3 = createElement(
              "div",
              {
                style: {
                  width: "8em",
                  height: "100px",
                  backgroundColor: "blue"
                }
              },
              [createText("font-size")]
            ))
          ]
        ))
      ]
    );

    BODY.appendChild(div);

    await snapshot();
  }); 

  it("should works with font size of own change", async (done) => {
    let div;
    let div2;
    let div3;
    div = createElement(
      "div",
      {
        style: {
          position: "relative",
          width: "200px",
          height: "200px",
          backgroundColor: "green"
        }
      },
      [
        (div2 = createElement(
          "div",
          {
            style: {
              width: "150px",
              height: "150px",
              backgroundColor: "yellow"
            }
          },
          [
            (div3 = createElement(
              "div",
              {
                style: {
                  width: "5em",
                  height: "100px",
                  backgroundColor: "blue"
                }
              },
              [createText("font-size")]
            ))
          ]
        ))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    window.requestAnimationFrame(async () => {
      div3.style.fontSize = '30px';
      await snapshot();
      done();
    })

  }); 

  it("should works with font size of parent change when own element has no font size", async (done) => {
    let div;
    let div2;
    let div3;
    div = createElement(
      "div",
      {
        style: {
          position: "relative",
          width: "200px",
          height: "200px",
          backgroundColor: "green"
        }
      },
      [
        (div2 = createElement(
          "div",
          {
            style: {
              width: "150px",
              height: "150px",
              backgroundColor: "yellow"
            }
          },
          [
            (div3 = createElement(
              "div",
              {
                style: {
                  width: "5em",
                  height: "100px",
                  backgroundColor: "blue"
                }
              },
              [createText("font-size")]
            ))
          ]
        ))
      ]
    );

    BODY.appendChild(div);
    
    await snapshot();

    window.requestAnimationFrame(async () => {
      div.style.fontSize = '30px';
      await snapshot();
      done();
    })

  }); 

  it("should works with font size of parent change when own element has font size", async (done) => {
    let div;
    let div2;
    let div3;
    div = createElement(
      "div",
      {
        style: {
          position: "relative",
          width: "200px",
          height: "200px",
          backgroundColor: "green"
        }
      },
      [
        (div2 = createElement(
          "div",
          {
            style: {
              width: "150px",
              height: "150px",
              backgroundColor: "yellow"
            }
          },
          [
            (div3 = createElement(
              "div",
              {
                style: {
                  fontSize: '20px',
                  width: "5em",
                  height: "100px",
                  backgroundColor: "blue"
                }
              },
              [createText("font-size")]
            ))
          ]
        ))
      ]
    );

    BODY.appendChild(div);

    await snapshot();

    window.requestAnimationFrame(async () => {
      div.style.fontSize = '30px';
      await snapshot();
      done();
    })

  }); 

});
