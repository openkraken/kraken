interface HostObject {}
interface Element {}

// https://html.spec.whatwg.org/multipage/form-elements.html#the-textarea-element
interface TextareaElement extends Element {
  defaultValue: string;
  value: string;
  cols: long;
  rows: long;
  wrap: string;
  autofocus: boolean;
  autocomplete: string;
  disabled: boolean;
  minLength: long;
  maxLength: long;
  name: string;
  placeholder: string;
  readonly: boolean;
  required: boolean;
  inputMode: string;
  focus(): void;
  blur(): void;
}
