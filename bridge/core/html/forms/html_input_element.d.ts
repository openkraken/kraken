import {HTMLElement} from "../html_element";

interface HTMLInputElement extends HTMLElement {
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
  minLength: number;
  maxLength: number;
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
