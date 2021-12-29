describe("rem", () => {
  it('should works with font size of html', async () => {
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
    document.documentElement.style.fontSize = '2rem';

    await snapshot();
  }); 

  it("should works with style other than font-size of html", async () => {
    document.documentElement.style.fontSize = '2rem';

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
                  width: "8rem",
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

  it("should works with html font size changes", async (done) => {
    let div;
    let div2;
    let div3;
    div = createElement(
      "div",
      {
        style: {
          position: "relative",
          width: "10rem",
          height: "10rem",
          backgroundColor: "green"
        }
      },
      [
        (div2 = createElement(
          "div",
          {
            style: {
              width: "8rem",
              height: "8rem",
              backgroundColor: "yellow"
            }
          },
          [
            (div3 = createElement(
              "div",
              {
                style: {
                  width: "6rem",
                  height: "6rem",
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
    document.documentElement.style.fontSize = '20px';

    await snapshot();

    window.requestAnimationFrame(async () => {
      document.documentElement.style.fontSize = '16px';
      await snapshot();
      done();
    });
  }); 
});
