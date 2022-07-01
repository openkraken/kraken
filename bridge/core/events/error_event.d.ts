import {ErrorEventInit} from "./error_event_init";
import {Event} from "../dom/events/event";

interface ErrorEvent extends Event {
  readonly message: string;
  readonly filename: string;
  readonly lineno: number;
  readonly colno: number;
  readonly error: any;
  new(eventType: string, init?: ErrorEventInit) : ErrorEvent;
}
