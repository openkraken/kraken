import {EventTarget} from "../dom/events/event_target";
import {ScrollOptions} from "../dom/scroll_options";
import {ScrollToOptions} from "../dom/scroll_to_options";
import {Screen} from "./screen";

interface Window extends EventTarget {
  open(url?: string): Window | null;
  scrollTo(options?: ScrollToOptions): void;
  scrollTo(x: number, y: number): void;
  scrollBy(options?: ScrollToOptions): void;
  scrollBy(x: number, y: number): void;

  postMessage(message: any, targetOrigin: string): void;
  postMessage(message: any): void;

  requestAnimationFrame(callback: Function): double;
  cancelAnimationFrame(request_id: double): void;

  readonly window: Window;
  readonly parent: Window;
  readonly self: Window;
  readonly screen: Screen;

  readonly scrollX: DartImpl<double>;
  readonly scrollY: DartImpl<double>;
  readonly devicePixelRatio: DartImpl<double>;
  readonly colorScheme: DartImpl<string>;
  readonly innerWidth: DartImpl<double>;
  readonly innerHeight: DartImpl<double>;

  new(): void;
}
