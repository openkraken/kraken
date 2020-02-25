import { krakenUIManager } from '../kraken';

const updateMessageQueue:string[] = [];
let updateRequested: boolean = false;

function requestUpdateFrame() {
  updateRequested = false;
  if (updateMessageQueue.length > 0) {
    krakenUIManager('["batchUpdate",[' + updateMessageQueue.join(',') + ']]');
    updateMessageQueue.length = 0;
  }
}

function sendMessage(message: string) {
  updateMessageQueue.push(message);
  if (!updateRequested) {
    updateRequested = true;
    requestAnimationFrame(requestUpdateFrame);
  }
}

export function createElement(type: string, id: number, props: any, events: any) {
  sendMessage(`["createElement",[{"id":${id},"type":"${type}","props":${JSON.stringify(props)},"events":${JSON.stringify(events)}}]]`);
}

export function createTextNode(id: number, nodeType: number, data: string) {
  sendMessage(`["createTextNode",[{"id":${id},"nodeType":${nodeType},"data":"${data}"}]]`);
}

export function insertAdjacentNode(parentNodeId: number, position: string, nodeId: number) {
  sendMessage(`["insertAdjacentNode",[${parentNodeId},"${position}",${nodeId}]]`);
}

export function removeNode(id: number) {
  sendMessage(`["removeNode",[${id}]]`);
}

export function setProperty(id: number, key: string, value: any) {
  sendMessage(`["setProperty",[${id},"${key}","${value}"]]`);
}

export function setStyle(id: number, key: string, value: string) {
  sendMessage(`["setStyle",[${id},"${key}","${value}"]]`);
}

export function addEvent(id: number, eventName: string) {
  sendMessage(`["addEvent",[${id},"${eventName}"]]`);
}

export function removeEvent(id: number, eventName: string) {
  sendMessage(`["removeEvent",[${id},"${eventName}"]]`);
}

export function method(id: number, eventName: string, params: any[]) {
  return krakenUIManager(`["method",[${id},"${eventName}", "${JSON.stringify(params)}"]]`);
}
