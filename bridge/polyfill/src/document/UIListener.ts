import { krakenUIListener } from '../kraken';
import { handleEvent } from './element';
import { getNodeById } from './node';

krakenUIListener((message) => {
  const parsed = JSON.parse(message);
  const nodeId = parsed[0];
  const event = parsed[1];
  const targetNode = getNodeById(nodeId);

  if (targetNode !== null) {
    handleEvent(targetNode, event);
  }
});
