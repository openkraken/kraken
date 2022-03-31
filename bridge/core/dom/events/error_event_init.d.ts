import {EventInit} from "./event_init";

// @ts-ignore
@Dictionary()
export interface ErrorEventInit extends EventInit {
  readonly error: any;
}
