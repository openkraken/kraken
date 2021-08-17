interface HostObject {}
interface HostClass {}

interface InputElement extends HostClass {
  width: number;
  height: number;
  value: string;
  accept: string;
  autocomplete: string;
  autofocus: boolean;
  checked: boolean;
  disabled: boolean;
  min: string;
  max: string;
  minlength: number;
  maxlength: number;
  size: number;
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
