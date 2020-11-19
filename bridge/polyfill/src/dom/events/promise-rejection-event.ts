import { Event } from './event';

export class PromiseRejectionEvent extends Event {
  promise: Promise<any>;
  reason?: any;
  constructor(eventInit?: PromiseRejectionEventInit) {
    super('unhandledrejection');

    if (eventInit) {
      this.promise = eventInit.promise;
      this.reason = eventInit.reason;
    }
  }
}
