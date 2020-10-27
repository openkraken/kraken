import { Event } from './event';

export class ErrorEvent extends Event {
  colno: number;
  error: any;
  filename: string;
  lineno: number;
  message: string;

  constructor(init?: ErrorEventInit) {
    super('error');
    if (init) {
      Object.assign(this, init);
    }
  }
}
