var container = document.createElement('div');

var div1 = document.createElement('div');
Object.assign(div1.style, {
  textAlign: "center",
  backgroundColor: "#f40",
});
div1.appendChild(document.createTextNode('flow layout text-align center'))
container.appendChild(div1);

var div2 = document.createElement('div');
Object.assign(div2.style, { "boxSizing": "border-box", "display": "flex", "flexDirection": "column", "alignContent": "flex-start", "flexShrink": 0, "position": "relative", "textAlign": "center", "backgroundColor": "green" });
div2.appendChild(document.createTextNode('flex layout text-align center'));
container.appendChild(div2);

document.body.appendChild(container);
