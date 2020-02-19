import { krakenUIListener } from '../kraken';
import { handleEvent } from './element';

krakenUIListener((message) => {
  let parsed = JSON.parse(message);
  const nodeId = parsed[0];
  const eventObj = parsed[1];
  handleEvent(nodeId, eventObj);
});