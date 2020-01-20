declare var __kraken_js_to_dart__: (data: string) => void;
declare var __kraken__createElement__: (type: string, id: number, props: string, events: string) => void;
declare var __kraken__setStyle__: (targetId: number, key: string, value: string) => void;
declare var __kraken__setProperty__: (targetId: number, key: string, value: string) => void;
declare var __kraken__removeNode__: (targetId: number) => void;
declare var __kraken__insertAdjacentNode__: (target: number, position: string, nodeId: number) => void;

export function krakenCreateElement(type: string, id: number, props: any, events: any) {
  __kraken__createElement__(type, id, JSON.stringify(props), JSON.stringify(events));
}

export function krakenCreateTextNode(id: number, nodeType: number, data: string) {
  // TODO check createTextNode Protocol
  return __kraken_js_to_dart__(`["createTextNode",[{"id":${id},"nodeType":${nodeType},"data":"${data}"}]]`);
}

export function krakenInsertAdjacentNode(parentNodeId: number, position: string, nodeId: number) {
  return __kraken__insertAdjacentNode__(parentNodeId, position, nodeId);
}

export function krakenRemoveNode(id: number) {
  return __kraken__removeNode__(id);
}

export function krakenSetProperty(id: number, key: string, value: any) {
  return __kraken__setProperty__(id, key, String(value));
}

export function krakenSetStyle(id: number, key: string, value: string) {
  return __kraken__setStyle__(id, key, value);
}

export function krakenAddEvent(id: number, eventName: string) {
  return __kraken_js_to_dart__(`["addEvent", [${id}, "${eventName}"]]`);
}

export function krakenRemoveEvent(id: number, eventName: string) {
  return __kraken_js_to_dart__(`["removeEvent", [${id}, "${eventName}"]]`);
}
