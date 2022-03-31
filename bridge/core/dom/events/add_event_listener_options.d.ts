// @ts-ignore
import {EventListenerOptions} from "./event_listener_options";

// @ts-ignore
@Dictionary()
export interface AddEventListenerOptions extends EventListenerOptions {
  passive: boolean;
  once: boolean;
}
