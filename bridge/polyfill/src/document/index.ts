
import { addKrakenUIListener } from '../bridge';
import { krakenUIListener } from './ui-listener';

addKrakenUIListener(krakenUIListener);

export { document } from './document';
