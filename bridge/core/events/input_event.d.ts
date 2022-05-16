import {Event} from "../dom/events/event";

interface InputEvent extends Event {
  readonly inputType: string;
  readonly data: string;
}
