var container = document.createElement('div');
Object.assign(container.style, { "boxSizing": "border-box", "display": "flex", "flexDirection": "column", "alignContent": "flex-start", "flexShrink": 0, "position": "relative" });

var div1 = document.createElement('div');
Object.assign(div1.style, { "boxSizing": "border-box", "display": "flex", "flexDirection": "column", "alignItems": "center", "alignContent": "flex-start", "flexShrink": 0, "position": "relative" });

var span = document.createElement('span');
span.appendChild(document.createTextNode('flex direction column 1'));
div1.appendChild(span);

var span2 = document.createElement('span');
span2.appendChild(document.createTextNode('flex direction column 2'));
div1.appendChild(span2);

container.appendChild(div1);

var div2 = document.createElement('div');
Object.assign(div2.style, { "boxSizing": "border-box", "display": "flex", "flexDirection": "column", "alignItems": "flex-end", "alignContent": "flex-start", "flexShrink": 0, "position": "relative" });

var span1 = document.createElement('span');
span1.appendChild(document.createTextNode('flex direction row 1'));
div2.appendChild(span1);

var span2 = document.createElement('span');
span2.appendChild(document.createTextNode('flex direction row 2'));
div2.appendChild(span2);

container.appendChild(div2);

document.body.appendChild(container);
