import {EventTarget} from "../dom/events/event_target";

export interface Screen extends EventTarget {
  readonly availWidth: DartImpl<double>;
  readonly availHeight: DartImpl<int64>;
  readonly width: DartImpl<int64>;
  readonly height: DartImpl<int64>;

  new(): void;
}
