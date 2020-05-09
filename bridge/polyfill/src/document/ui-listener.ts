// import { krakenUIListener } from '../bridge';
import { getNodeByNodeId } from './document';

export function krakenUIListener(message: any) {
  const parsed = JSON.parse(message);
  const targetId = parsed[0];
  const event = parsed[1];
  const currentTarget = getNodeByNodeId(targetId);

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
}
