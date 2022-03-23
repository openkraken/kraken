interface HostObject {}
interface Element {}

interface InputElement extends Element {
  width: number;
  height: number;
  defaultValue: string;
  value: string;
  accept: string;
  autocomplete: string;
  autofocus: boolean;
  checked: boolean;
  disabled: boolean;
  min: string;
  max: string;
  minLength: long;
  maxLength: long;
  size: long;
  multiple: boolean;
  name: string;
  step: string;
  pattern: string;
  required: boolean;
  readonly: boolean;
  placeholder: string
  type: string;
  focus(): void;
  blur(): void;
}
