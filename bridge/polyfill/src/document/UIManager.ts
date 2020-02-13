import { krakenUIManager } from '../kraken';

// Timeout for batch updater, default to 60 fps.
const FRAME_TICK_TIMEOUT = 1000 / 60;
// Auto negotiation whether to enable batch update.
let batchUpdateEnabled:boolean = false;
let updateFrameTimer:any;
const updateMessageQueue:string[] = [];

export function enableBatchUpdate() {
  batchUpdateEnabled = true;
}

export function requestUpdateFrame() {
  if (updateFrameTimer !== undefined) clearTimeout(updateFrameTimer);
  updateFrameTimer = setTimeout(requestUpdateFrame, FRAME_TICK_TIMEOUT);
  if (updateMessageQueue.length > 0) {
    krakenUIManager('["batchUpdate",[' + updateMessageQueue.join(',') + ']]');
    updateMessageQueue.length = 0;
  }
}

function sendMessage(message: string) {
  if (batchUpdateEnabled) {
    updateMessageQueue.push(message);
  } else {
    krakenUIManager(message);
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
