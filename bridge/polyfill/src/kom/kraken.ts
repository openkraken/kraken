import { krakenModuleListener } from '../modules/module-listener';
import { addKrakenModuleListener } from '../bridge';
import { methodChannel } from '../modules/method-channel';

addKrakenModuleListener(krakenModuleListener);

export const kraken = {
  methodChannel,
};
