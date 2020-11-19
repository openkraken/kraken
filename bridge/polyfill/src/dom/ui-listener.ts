// import { krakenUIListener } from '../bridge';
import { getNodeByTargetId } from './document';

export function krakenUIListener(message: any) {
  console.log(message);
  const parsed = JSON.parse(message);
  const targetId = parsed[0];
  const event = parsed[1];
  const currentTarget = getNodeByTargetId(targetId);

  if (currentTarget !== null) {
    const target = getNodeByTargetId(event.target);
    event.targetId = event.target;
    event.target = target;

    event.currentTargetId = event.currentTarget;
    event.currentTarget = currentTarget;

    if (currentTarget.dispatchEvent) {
      currentTarget.dispatchEvent(event);
    }
  }
}
