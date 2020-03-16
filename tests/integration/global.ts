function setStyle(dom: any, object: any) {
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}
