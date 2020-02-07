import { krakenJSToDart } from '../kraken';

// Timeout for batch updater, default to 60 fps.
const FRAME_TICK_TIMEOUT = 1000 / 60;

// Auto negotiation whether to enable batch update.
let isEnableBatchUpdate:boolean = false;
let frameTimeoutTimer:any;

export function enableBatchUpdate() {
  isEnableBatchUpdate = true;
}

const tickMessageQueue:string[] = [];

export function frameTick() {
  if (frameTimeoutTimer !== undefined) clearTimeout(frameTimeoutTimer);
  frameTimeoutTimer = setTimeout(frameTick, FRAME_TICK_TIMEOUT);
  if (tickMessageQueue.length > 0) {
    krakenJSToDart('["batchUpdate",[' + tickMessageQueue.join(',') + ']]');
    tickMessageQueue.length = 0;
  }
}

export function createElement(type: string, id: number, props: any, events: any) {
  const message = `["createElement", [{"id":${id},"type":"${type}","props":${JSON.stringify(props)},"events":${JSON.stringify(events)}}]]`;
  if (isEnableBatchUpdate) {
    tickMessageQueue.push(message);
  } else {
    krakenJSToDart(message);
  }
}

export function createTextNode(id: number, nodeType: number, data: string) {
  const message = `["createTextNode",[{"id":${id},"nodeType":${nodeType},"data":"${data}"}]]`;
  if (isEnableBatchUpdate) {
    tickMessageQueue.push(message);
  } else {
    krakenJSToDart(message);
  }
}

export function insertAdjacentNode(parentNodeId: number, position: string, nodeId: number) {
  const message = `["insertAdjacentNode",[${parentNodeId},"${position}",${nodeId}]]`;
  if (isEnableBatchUpdate) {
    tickMessageQueue.push(message);
  } else {
    krakenJSToDart(message);
  }
}

export function removeNode(id: number) {
  const message = `["removeNode",[${id}]]`;
  if (isEnableBatchUpdate) {
    tickMessageQueue.push(message);
  } else {
    krakenJSToDart(message);
  }
}

export function setProperty(id: number, key: string, value: any) {
  const message = `["setProperty",[${id},"${key}","${value}"]]`;
  if (isEnableBatchUpdate) {
    tickMessageQueue.push(message);
  } else {
    krakenJSToDart(message);
  }
}

export function setStyle(id: number, key: string, value: string) {
  const message = `["setStyle",[${id},"${key}","${value}"]]`;
  if (isEnableBatchUpdate) {
    tickMessageQueue.push(message);
  } else {
    krakenJSToDart(message);
  }
}

export function addEvent(id: number, eventName: string) {
  const message = `["addEvent",[${id},"${eventName}"]]`;
  if (isEnableBatchUpdate) {
    tickMessageQueue.push(message);
  } else {
    krakenJSToDart(message);
  }
}

export function removeEvent(id: number, eventName: string) {
  const message = `["removeEvent",[${id},"${eventName}"]]`;
  if (isEnableBatchUpdate) {
    tickMessageQueue.push(message);
  } else {
    krakenJSToDart(message);
  }
}
