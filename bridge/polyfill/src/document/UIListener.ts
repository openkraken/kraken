import { krakenUIListener } from '../kraken';
import { enableBatchUpdate, requestUpdateFrame } from './UIManager';
import { handleEvent } from './element';

const FRAME_BEGIN = '$';
krakenUIListener((message) => {
  if (message[0] === FRAME_BEGIN) {
    enableBatchUpdate();
    requestUpdateFrame();
    return;
  }

  let parsedMessage = null;
  try {
    parsedMessage = JSON.parse(message);
  } catch (err) {
    console.error('Can not parse message from backend, the raw message:', message);
    console.error(err);
  }

  if (parsedMessage !== null) {
    try {
      const type = parsedMessage[0];
      if (type === 'event') {
        const nodeId = parsedMessage[1][0];  
        const arg = parsedMessage[1][1];
        handleEvent(nodeId, arg);
      } else {
        console.error(`ERROR: Unknown event type ${type} from backend}`);
      }
    } catch (err) {
      console.log(err.message);
    }
  }
});