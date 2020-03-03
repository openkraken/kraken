import {krakenUIManager, krakenRequestBatchUpdate, krakenToBlob} from '../kraken';
import {Blob} from "../blob";

const updateMessageQueue:string[] = [];
let updateRequested: boolean = false;

export function requestUpdateFrame() {
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
    krakenRequestBatchUpdate(requestUpdateFrame);
  }
}

export function createElement(type: string, id: number, props: any, events: any) {
  sendMessage(`["createElement",[${id},"${type}",${JSON.stringify(props)},${JSON.stringify(events)}]]`);
}

export function createTextNode(id: number, data: string) {
  sendMessage(`["createTextNode",[${id},"${data}"]]`);
}

export function createComment(id: number, data: string) {
  sendMessage(`["createComment",[${id},"${data}"]]`);
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

export function removeProperty(id: number, key: string) {
  sendMessage(`["removeProperty",[${id},"${key}"]]`);
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

export function method(id: number, methodName: string, params?: any[]) {
  // Must flush batch update before get
  requestUpdateFrame();
  return krakenUIManager(`["method",[${id},"${methodName}",${params ? JSON.stringify(params): '[]'}]]`);
}

export function toBlob(id: number) {
  // need to flush all pending frame messages
  requestUpdateFrame();
  return new Promise((resolve, reject) => {
    krakenToBlob(id, (err, blob) => {
      if (err) {
        return reject(new Error(err));
      }

      resolve(new Blob([blob]));
    });
  });
}