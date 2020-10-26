import { krakenModuleListener } from './module-listener';
import { addKrakenModuleListener } from './bridge';
import { methodChannel } from './method-channel';

addKrakenModuleListener(krakenModuleListener);

export const kraken = {
  methodChannel,
};
