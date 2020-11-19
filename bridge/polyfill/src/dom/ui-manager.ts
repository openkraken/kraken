import { krakenUIManager, krakenRequestBatchUpdate, krakenToBlob } from './bridge';
import { EventType, getEventTypeOfName } from './events/event';

const updateMessageQueue: any[] = [];
let updateRequested: boolean = false;

function appendMessage(message: any[]) {
  updateMessageQueue.push(message);
  if (!updateRequested) {
    updateRequested = true;
    krakenRequestBatchUpdate(requestUpdateFrame);
  }
}

function sendMessage(message: any[]) {
  let response = krakenUIManager(JSON.stringify(message));
  handleUIResponse(response);
  return response;
}

function handleUIResponse(response: string) {
  if (response.indexOf('Error:') >= 0) {
    throw new Error(response);
  }
}

export function requestUpdateFrame() {
  updateRequested = false;
  if (updateMessageQueue.length > 0) {
    try {
      // Make sure message queue is cleared, no matter that dart throws error or not.
      let message = JSON.stringify(['batchUpdate', updateMessageQueue]);
      // Clear updateMessageQueue before send BatchUpdate into Flutter to prevent duplicate messages.
      updateMessageQueue.length = 0;
      let response = krakenUIManager(message);
      handleUIResponse(response);
    } catch (err) {
      // TODO: needs to remove this log when element bindings works had complete.
      console.error(err);
    }
  }
}

export function createElement(type: string, id: number) {
  appendMessage(['createElement', [id, type]]);
}

export function createTextNode(id: number, data: string) {
  appendMessage(['createTextNode', [id, data]]);
}

export function createComment(id: number, data: string) {
  appendMessage(['createComment', [id, data]]);
}

export function insertAdjacentNode(parentNodeId: number, position: string, targetId: number) {
  appendMessage(['insertAdjacentNode', [parentNodeId, position, targetId]]);
}

export function removeNode(id: number) {
  appendMessage(['removeNode', [id]]);
}

export function setProperty(id: number, key: string, value: any) {
  appendMessage(['setProperty', [id, key, value]]);
}

export function getProperty(id: number, key: string) {
  // Must flush batch update before get
  requestUpdateFrame();
  return sendMessage(['getProperty', [id, key]]);
}

export function removeProperty(id: number, key: string) {
  appendMessage(['removeProperty', [id, key]]);
}

export function setStyle(id: number, key: string, value: string) {
  appendMessage(['setStyle', [id, key, value]]);
}

export function addEvent(id: number, eventType: EventType) {
  appendMessage(['addEvent', [id, eventType]]);
}

export function removeEvent(id: number, eventName: string) {
  appendMessage(['removeEvent', [id, eventName]]);
}

export function method(id: number, methodName: string, params: any[] = []) {
  // Must flush batch update before get
  requestUpdateFrame();
  return sendMessage(['method', [id, methodName, params]]);
}

export function toBlob(targetId: number, devicePixelRatio: number) {
  // need to flush all pending frame messages
  requestUpdateFrame();
  return new Promise((resolve, reject) => {
    krakenToBlob(targetId, devicePixelRatio, (err, blob) => {
      if (err) {
        return reject(new Error(err));
      }

      resolve(new Blob([blob]));
    });
  });
}
