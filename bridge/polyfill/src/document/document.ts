import { Node, NodeType, traverseNode } from './node';
import { Element } from './element';
import { Comment } from './comment';
import { TextNode } from './text';
import { ElementRegistry } from './element-registry';
import { BODY, WINDOW, eventTargetMap } from './events/event-target';
import { cookie } from '../cookie';
import { HTMLAllCollection } from './collection';

const elementMapById = {};

export class Document extends Node {
  private bodyElement = new Element('BODY', BODY);
  public body: Element = this.bodyElement;
  // @TODO Need to implement complete document tree model, equal to body temporary
  public documentElement: Element = this.bodyElement;
  public nodeName: string = '#document';
  public nodeType = NodeType.DOCUMENT_NODE;

  constructor() {
    // Use the same targetId with body, only used in event targets,
    // document events are triggered and received by body element.
    super(NodeType.DOCUMENT_NODE, BODY);
  }

  public getElementById(elementid: string): null | Element {
    const argLength = arguments.length;
    if (argLength < 1) throw new Error(`Uncaught TypeError: Failed to execute 'getElementById' on 'Document': 1 argument required, but only 0 present.`);
    if (elementid === '') {
      return null;
    }
    let id = elementid;
    // Defined by the special condition
    // When set Element id attribute with string type: 'null', 'undefined',
    // getElementById can find it by null, undefined.
    if (!id) {
      id = String(id);
    }
    const mapEntity = elementMapById[id];
    if (!mapEntity) {
      return null;
    }
    if (mapEntity.element) {
      return mapEntity.element;
    }
    let element: Element | null = null;
    traverseNode(this.body, (node: Node) => {
      if (node instanceof Element && node.getAttribute('id') === elementid) {
        if (!element) {
          element = node;
        }
        return true;
      }
      return false;
    });
    return element;
  }

  createElement(tagName: string) : Element {
    const ElementConstructor = ElementRegistry.get(tagName) || Element;
    return new ElementConstructor(tagName);
  }

  createTextNode(text: string) {
    return new TextNode(text);
  }

  /**
   * createComment() creates a new comment node, and returns it.
   * @param data {string} A string containing the data to be added to the Comment.
   */
  createComment(data: string) {
    return new Comment(data);
  }

  get all(): HTMLAllCollection {
    const all = new HTMLAllCollection();
    traverseNode(document, (node: Node) => {
      all.add(node);
    });
    return all;
  }

  get cookie() {
    return cookie.get();
  }

  set cookie(str: String) {
    cookie.set(str);
  }
}

export const document = new Document();

export function getNodeByTargetId(targetId: number) : Node|null|Window {
  if (targetId === WINDOW) {
    return window;
  }

  if (eventTargetMap.hasOwnProperty(targetId)) {
    const eventTarget = eventTargetMap[targetId];
    if (eventTarget instanceof Node) {
      return eventTarget;
    }
  }

  return null;
}

export function removeElementById(elementid: string, element: Element): void {
  const mapEntity = elementMapById[elementid];
  if (mapEntity && mapEntity.elementList) {
    if (mapEntity.elementList.length === 0) {
      delete elementMapById[elementid];
    } else {
      mapEntity.elementList = mapEntity.elementList.filter((item: Element) => item !== element);
      if (mapEntity.elementList.length === 1) {
        [mapEntity.element] = mapEntity.elementList;
        mapEntity.elementList = [];
      }
    }
  }
}

export function addElementById(elementid: string, element: Element): void {
  const mapEntity = elementMapById[elementid];
  if (mapEntity) {
    if (mapEntity.elementList.length > 0) {
      mapEntity.elementList.push(element);
    } else {
      mapEntity.elementList = [element, mapEntity.element];
      mapEntity.element = null;
    }
  } else {
    const newEntity = { element, elementList: [] };
    elementMapById[elementid] = newEntity;
  }
}
