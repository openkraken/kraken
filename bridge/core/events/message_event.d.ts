import {Event} from "../dom/events/event";
import {MessageEventInit} from "./message_event_init";

export interface MessageEvent extends Event {
  new(type: string, init?: MessageEventInit): MessageEvent;
  readonly data: any;
  readonly origin: string;
  readonly lastEventId: string;
  readonly source: string;
}
