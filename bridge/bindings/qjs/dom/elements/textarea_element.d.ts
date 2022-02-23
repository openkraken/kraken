interface HostObject {}
interface Element {}

// https://html.spec.whatwg.org/multipage/form-elements.html#the-textarea-element
interface TextareaElement extends Element {
  autofocus: boolean;
  autocomplete: string;
  cols: number;
  disabled: boolean;
  minlength: number;
  maxlength: number;
  name: string;
  placeholder: string;
  readonly: boolean;
  required: boolean;
  rows: number;
  wrap: string;
  focus(): void;
  blur(): void;
}
