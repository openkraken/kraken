import { krakenUIListener } from '../kraken';
import { getNodeByNodeId } from './document';

krakenUIListener((message) => {
  const parsed = JSON.parse(message);
  const nodeId = parsed[0];
  const event = parsed[1];
  const currentTarget = getNodeByNodeId(nodeId);

  if (currentTarget !== null) {
    const target = getNodeByNodeId(event.target);
    event.targetId = event.target;
    event.target = target;

    event.currentTargetId = event.currentTarget;
    event.currentTarget = currentTarget;

    if (currentTarget.dispatchEvent) {
      currentTarget.dispatchEvent(event);
    }
  }
});
