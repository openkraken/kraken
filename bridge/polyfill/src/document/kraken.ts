declare var __kraken_js_to_dart__: (dart: string) => void;

const tickMessageQueue:string[] = [];

function tick() {
  if (tickMessageQueue.length > 0) {
    __kraken_js_to_dart__('["batchUpdate",[' + tickMessageQueue.join(',') + ']]');
    tickMessageQueue.length = 0;
  }
  requestAnimationFrame(tick);
}

setTimeout(() => {
  requestAnimationFrame(tick);
});

export function krakenCreateElement(type: string, id: number, props: any, events: any) {
  tickMessageQueue.push(`["createElement", [{"id":${id},"type":"${type}","props":${JSON.stringify(props)},"events":${JSON.stringify(events)}}]]`);
}

export function krakenCreateTextNode(id: number, nodeType: number, data: string) {
  tickMessageQueue.push(`["createTextNode",[{"id":${id},"nodeType":${nodeType},"data":"${data}"}]]`);
}

export function krakenInsertAdjacentNode(parentNodeId: number, position: string, nodeId: number) {
  tickMessageQueue.push(`["insertAdjacentNode",[${parentNodeId},"${position}",${nodeId}]]`);
}

export function krakenRemoveNode(id: number) {
  tickMessageQueue.push(`["removeNode",[${id}]]`);
}

export function krakenSetProperty(id: number, key: string, value: any) {
  tickMessageQueue.push(`["setProperty",[${id},"${key}","${value}"]]`);
}

export function krakenSetStyle(id: number, key: string, value: string) {
  tickMessageQueue.push(`["setStyle",[${id},"${key}","${value}"]]`);
}

export function krakenAddEvent(id: number, eventName: string) {
  tickMessageQueue.push(`["addEvent",[${id},"${eventName}"]]`);
}

export function krakenRemoveEvent(id: number, eventName: string) {
  tickMessageQueue.push(`["removeEvent",[${id},"${eventName}"]]`);
}
