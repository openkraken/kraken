import { Node, NodeType, traverseNode } from './node';
import { Element } from './element';
import { Comment } from './comment';
import { TextNode } from './text';
import { ElementRegistry } from './element-registry';
import { BODY, WINDOW, eventTargetMap } from './events/event-target';
import { cookie } from '../cookie';
import { HTMLAllCollection } from './collection';

interface MapElement {
  orderList: Array<Element|null>|null,
  element: Element|null,
  count: number
}

export const m_elementsById = {};
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

  public getElementById(elementid:string) : null | Element {
    const argLength = arguments.length;
    if (argLength < 1) throw new Error(`Uncaught TypeError: Failed to execute 'getElementById' on 'Document': 1 argument required, but only ${argLength} present.`);
    if (elementid === '' || elementid === null || elementid === undefined) {
      return null;
    }
    if (Object.keys(m_elementsById).length === 0) {
      return null;
    }
    const entry = m_elementsById[elementid];
    if (!entry) {
      return null;
    }
    if (entry.element && entry.element !== undefined && entry.element != null) {
      return entry.element;
    }
    let element: Element| null = null;
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

  public addElementById(elementid:string, element: Element) :void {
    const mapEntity = m_elementsById[elementid];
    if (mapEntity) {
      if (mapEntity.count === 1) {
        mapEntity.count += 1;
        mapEntity.orderList = [element, mapEntity.element];
        mapEntity.element = null;
      } else if (mapEntity.count !== 1) {
        mapEntity.count += 1;
        mapEntity.orderList.push(element);
      }
    } else {
      const newEntity:MapElement = { count: 1, element, orderList: null };
      m_elementsById[elementid] = newEntity;
    }
  }

  public removeElementById(elementid:string, element:Element) :void {
    const mapEntity = m_elementsById[elementid];
    if (mapEntity && mapEntity.count === 1) {
      delete m_elementsById[elementid];
    }
    if (mapEntity && mapEntity.count === 2) {
      mapEntity.count -= 1;
      mapEntity.element = mapEntity.orderList[0] === element ?
        mapEntity.orderList[1] : mapEntity.orderList[0];
      mapEntity.orderList = null;
    }
    if (mapEntity && mapEntity.count > 2) {
      mapEntity.count -= 1;
      mapEntity.orderList = mapEntity.orderList.filter((value: Element) => { return value !== element; });
    }
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
