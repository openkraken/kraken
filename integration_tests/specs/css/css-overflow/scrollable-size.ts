describe('scrollable-size', () => {
  it('works with html', async () => {
    let div1 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'grey'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '500px',
          height: '100px',
          backgroundColor: 'lightgrey'
        }
      })
    ]);
    let div2 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'green'
      }
    }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '700px',
          marginTop: '177px',
          backgroundColor: 'lightgreen'
        }
      })
    ]);
    let div3 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'blue'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
        }
      }, [
        createElement('div', {
          style: {
            width: '533px',
            height: '50px',
            backgroundColor: 'pink'
          }
        }),
      ])
    ]);

    let div = createElement('div', {
      style: {
        width: '350px',
        height: '350px',
        padding: '25px',
        backgroundColor: 'yellow',
      }
    });

    div.appendChild(div1);
    div.appendChild(div2);
    div.appendChild(div3);

    BODY.appendChild(div);

    await snapshot();
    document.documentElement.scrollTo(2000, 2000);
    await snapshot(0.2);
  });

  it('works with flow layout', async () => {
    let div1 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'grey'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '500px',
          height: '100px',
          backgroundColor: 'lightgrey'
        }
      })
    ]);
    let div2 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'green'
      }
    }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '300px',
          marginTop: '177px',
          backgroundColor: 'lightgreen'
        }
      })
    ]);
    let div3 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'blue'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
        }
      }, [
        createElement('div', {
          style: {
            width: '533px',
            height: '50px',
            backgroundColor: 'pink'
          }
        }),
      ])
    ]);

    let div = createElement('div', {
      style: {
        overflow: 'scroll',
        width: '350px',
        height: '350px',
        padding: '25px',
        backgroundColor: 'yellow',
      }
    });

    div.appendChild(div1);
    div.appendChild(div2);
    div.appendChild(div3);

    BODY.appendChild(div);

    await snapshot();
    div.scrollTo(2000, 2000);
    await snapshot(0.2);
  });

  it('works with flex layout and flex wrap in row direction', async () => {
    let div1 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'grey'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '500px',
          height: '100px',
          backgroundColor: 'lightgrey'
        }
      })
    ]);
    let div2 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'green'
      }
    }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '300px',
          marginTop: '177px',
          backgroundColor: 'lightgreen'
        }
      })
    ]);
    let div3 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'blue'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
        }
      }, [
        createElement('div', {
          style: {
            width: '533px',
            height: '50px',
            backgroundColor: 'pink'
          }
        }),
      ])
    ]);

    let div = createElement('div', {
      style: {
        overflow: 'scroll',
        display: 'flex',
        flexWrap: 'wrap',
        width: '350px',
        height: '350px',
        padding: '25px',
        backgroundColor: 'yellow',
      }
    });

    div.appendChild(div1);
    div.appendChild(div2);
    div.appendChild(div3);

    BODY.appendChild(div);

    await snapshot();
    div.scrollTo(2000, 2000);
    await snapshot(0.2);
  });

  it('works with flex layout and flex wrap in column direction', async () => {
    let div1 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '150px',
        backgroundColor: 'grey'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '500px',
          height: '100px',
          backgroundColor: 'lightgrey'
        }
      })
    ]);
    let div2 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '150px',
        backgroundColor: 'green'
      }
    }, [
      createElement('div', {
        style: {
          width: '550px',
          height: '100px',
          backgroundColor: 'lightgreen'
        }
      })
    ]);
    let div3 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '150px',
        backgroundColor: 'blue'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '250px',
          height: '100px',
          backgroundColor: 'lightblue',
        }
      }, [
        createElement('div', {
          style: {
            width: '100px',
            height: '350px',
            backgroundColor: 'pink'
          }
        }),
      ])
    ]);

    let div = createElement('div', {
      style: {
        overflow: 'scroll',
        display: 'flex',
        flexDirection: 'column',
        flexWrap: 'wrap',
        width: '350px',
        height: '350px',
        padding: '25px',
        backgroundColor: 'yellow',
      }
    });

    div.appendChild(div1);
    div.appendChild(div2);
    div.appendChild(div3);

    BODY.appendChild(div);

    await snapshot();
    div.scrollTo(2000, 2000);
    await snapshot(0.2);
  });

  it('works with positioned element in flow layout', async () => {
    let div1 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'grey'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '500px',
          height: '100px',
          backgroundColor: 'lightgrey'
        }
      })
    ]);
    let div2 = createElement('div', {
      style: {
        position: 'absolute',
        top: '300px',
        left: '150px',
        overflow: 'scroll',
        display: 'inline-block',
        width: '150px',
        height: '150px',
        backgroundColor: 'green'
      }
    }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '300px',
          backgroundColor: 'lightgreen'
        }
      })
    ]);
    let div3 = createElement('div', {
      style: {
        position: 'absolute',
        top: '100px',
        left: '300px',
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'blue'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '300px',
          height: '100px',
          backgroundColor: 'lightblue',
        }
      }, [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            backgroundColor: 'pink'
          }
        }),
      ])
    ]);

    let div = createElement('div', {
      style: {
        overflow: 'scroll',
        position: 'relative',
        width: '350px',
        height: '350px',
        padding: '25px',
        backgroundColor: 'yellow',
      }
    });

    div.appendChild(div1);
    div.appendChild(div2);
    div.appendChild(div3);

    BODY.appendChild(div);

    await snapshot();
    div.scrollTo(2000, 2000);
    await snapshot(0.2);
  });

  it('works with positioned element in flex layout', async () => {
    let div1 = createElement('div', {
      style: {
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'grey'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '500px',
          height: '100px',
          backgroundColor: 'lightgrey'
        }
      })
    ]);
    let div2 = createElement('div', {
      style: {
        position: 'absolute',
        top: '300px',
        left: '150px',
        overflow: 'scroll',
        display: 'inline-block',
        width: '150px',
        height: '150px',
        backgroundColor: 'green'
      }
    }, [
      createElement('div', {
        style: {
          width: '100px',
          height: '300px',
          backgroundColor: 'lightgreen'
        }
      })
    ]);
    let div3 = createElement('div', {
      style: {
        position: 'absolute',
        top: '100px',
        left: '300px',
        display: 'inline-block',
        width: '150px',
        height: '200px',
        backgroundColor: 'blue'
      }
    }, [
      createElement('div', {
        style: {
          display: 'block',
          width: '300px',
          height: '100px',
          backgroundColor: 'lightblue',
        }
      }, [
        createElement('div', {
          style: {
            width: '50px',
            height: '50px',
            backgroundColor: 'pink'
          }
        }),
      ])
    ]);

    let div = createElement('div', {
      style: {
        overflow: 'scroll',
        position: 'relative',
        display: 'flex',
        width: '350px',
        height: '350px',
        padding: '25px',
        backgroundColor: 'yellow',
      }
    });

    div.appendChild(div1);
    div.appendChild(div2);
    div.appendChild(div3);

    BODY.appendChild(div);

    await snapshot();
    div.scrollTo(2000, 2000);
    await snapshot(0.2);
  });

  it('scrollable size should include padding of flow layout', async (done) => {
    let div;
    div = createElement(
      'div',
      {
        style: {
           height: '300px',
           border: '10px solid black',
           padding: '30px',
           overflow: 'scroll',
           backgroundColor: 'yellow'
         },
      },
      [
        createElement('div', {
          style: {
            margin: '20px',
            width: '500px',
            height: '400px',
            background: 'green',
          }
        })
      ]
    );
    BODY.appendChild(div);

    requestAnimationFrame(async () => {
       div.scrollTo(1000, 1000);
       await snapshot();
       done();
    });
  });

  it('scrollable size should include padding of flex layout', async (done) => {
    let div;
    div = createElement(
      'div',
      {
        style: {
           display: 'flex',
           border: '10px solid black',
           height: '300px',
           padding: '30px',
           overflow: 'scroll',
           backgroundColor: 'yellow'
         },
      },
      [
        createElement('div', {
          style: {
            margin: '20px',
            width: '500px',
            height: '400px',
            background: 'green',
            flexShrink: 0,
          }
        })
      ]
    );
    BODY.appendChild(div);

    requestAnimationFrame(async () => {
       div.scrollTo(1000, 1000);
       await snapshot();
       done();
    });
  });
});
