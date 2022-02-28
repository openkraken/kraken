interface HostObject {}
interface Element {}

// https://html.spec.whatwg.org/multipage/form-elements.html#the-textarea-element
interface TextareaElement extends Element {
  defaultValue: string;
  value: string;
  cols: number;
  rows: number;
  wrap: string;
  autofocus: boolean;
  autocomplete: string;
  disabled: boolean;
  minlength: number;
  maxlength: number;
  name: string;
  placeholder: string;
  readonly: boolean;
  required: boolean;
  focus(): void;
  blur(): void;
}
