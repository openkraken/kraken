declare var __kraken_js_to_dart__: (data: string) => void;

export function krakenCreateElement(type: string, id: number, props: any, events: string[]) {
  return __kraken_js_to_dart__(`["createElement",[{"type":"${type.toUpperCase()}","id":${id},"props":${JSON.stringify(props)},"events":${JSON.stringify(events)}}]]`);
}

export function krakenCreateTextNode(id: number, nodeType: number, data: string) {
  return __kraken_js_to_dart__(`["createTextNode",[{"id":${id},"nodeType":${nodeType},"data":"${data}"}]]`);
}

export function krakenInsertAdjacentNode(parentNodeId: number, position: string, nodeId: number) {
  return __kraken_js_to_dart__(`["insertAdjacentNode",[${parentNodeId},"${position}",${nodeId}]]`);
}

export function krakenRemoveNode(id: number) {
  return __kraken_js_to_dart__(`["removeNode",[${id}]]`);
}

export function krakenSetProperty(id: number, key: string, value: string) {
  return __kraken_js_to_dart__(`["setProperty",[${id},"${key}","${value}"]]`);
}
