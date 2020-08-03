import { Node, NodeType, traverseNode } from './node';
import { Element } from './element';
import { Comment } from './comment';
import { TextNode } from './text';
import { ElementRegistry } from './element-registry';
import { BODY, WINDOW, eventTargetMap } from './events/event-target';
import { cookie } from '../cookie';
import { HTMLAllCollection } from './collection';

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
  
  getElementById(id: string): Element|null {
    if(id==''){
      return null
    }
    for (let key in eventTargetMap){
      const element=eventTargetMap[key];
      if( element instanceof Element && element.getAttribute('id')===id){
          return element;
      }
    }
    return null;
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
