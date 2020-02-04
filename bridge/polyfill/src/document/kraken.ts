declare var __kraken_js_to_dart__: (dart: string) => void;

const tickMessageQueue:string[] = [];

export function frameTick() {
  if (tickMessageQueue.length > 0) {
    __kraken_js_to_dart__('["batchUpdate",[' + tickMessageQueue.join(',') + ']]');
    tickMessageQueue.length = 0;
  }
}

export function createElement(type: string, id: number, props: any, events: any) {
  tickMessageQueue.push(`["createElement", [{"id":${id},"type":"${type}","props":${JSON.stringify(props)},"events":${JSON.stringify(events)}}]]`);
}

export function createTextNode(id: number, nodeType: number, data: string) {
  tickMessageQueue.push(`["createTextNode",[{"id":${id},"nodeType":${nodeType},"data":"${data}"}]]`);
}

export function insertAdjacentNode(parentNodeId: number, position: string, nodeId: number) {
  tickMessageQueue.push(`["insertAdjacentNode",[${parentNodeId},"${position}",${nodeId}]]`);
}

export function removeNode(id: number) {
  tickMessageQueue.push(`["removeNode",[${id}]]`);
}

export function setProperty(id: number, key: string, value: any) {
  tickMessageQueue.push(`["setProperty",[${id},"${key}","${value}"]]`);
}

export function setStyle(id: number, key: string, value: string) {
  tickMessageQueue.push(`["setStyle",[${id},"${key}","${value}"]]`);
}

export function addEvent(id: number, eventName: string) {
  tickMessageQueue.push(`["addEvent",[${id},"${eventName}"]]`);
}

export function removeEvent(id: number, eventName: string) {
  tickMessageQueue.push(`["removeEvent",[${id},"${eventName}"]]`);
}
