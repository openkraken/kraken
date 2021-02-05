import { krakenModuleListener } from '../modules/module-listener';
import { addKrakenModuleListener, krakenInvokeModule, privateKraken } from '../bridge';
import { methodChannel } from '../modules/method-channel';

addKrakenModuleListener(krakenModuleListener);

export const kraken = {
  ...privateKraken,
  methodChannel,
  invokeModule: krakenInvokeModule,
  addKrakenModuleListener: addKrakenModuleListener
};
