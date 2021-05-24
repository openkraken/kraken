// This file is forked form https://github.com/vanilla-jsx/vanilla-jsx/blob/main/packages/jsx-runtime/index.js
import flatten from 'lodash.flattendeep';

export function jsx(tag, { ref, children, ...props } = {}) {
  if (typeof tag === 'string') {
    const element = document.createElement(tag);

    Object.keys(props).forEach((key) => {
      if (!props[key]) {

      } else if (typeof props[key] === 'function') {
        element[key] = props[key];
      } else if (key === 'style') {
        Object.assign(element.style, props[key]);
      } else {
        element.setAttribute(key, props[key]);
      }
    });

    if (!children) {

    } else {
      children = Array.isArray(children) ? flatten(children) : [children];

      children.forEach((child) => {
        if (typeof child === 'string') {
          child = document.createTextNode(child);
        }
        child && element.appendChild(child);
      });
    }

    if (!ref) {

    } else if (typeof ref === 'function') {
      ref(element);
    } else {
      element.setAttribute('ref', ref)
    }

    return element;
  } else if (typeof tag === 'function') {
    return tag({ ref, children, ...props });
  } else {
    console.error('Unknown tag:', tag);
  }
}

export const jsxs = jsx;

export function Fragment({ children } = {}) {
  const element = document.createDocumentFragment();

  if (!children) {

  } else {
    children = Array.isArray(children) ? flatten(children) : [children];

    children.forEach((child) => {
      child && element.append(child);
    });
  }

  return element;
}