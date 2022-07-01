import {Element} from "../dom/element";

// https://html.spec.whatwg.org/multipage/form-elements.html#the-textarea-element
interface HTMLTextAreaElement extends Element {
  defaultValue: string;
  value: string;
  cols: double;
  rows: double;
  wrap: string;
  autofocus: boolean;
  autocomplete: string;
  disabled: boolean;
  minLength: double;
  maxLength: double;
  name: string;
  placeholder: string;
  readonly: boolean;
  required: boolean;
  inputMode: string;
  focus(): void;
  blur(): void;
}
