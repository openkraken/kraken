interface Event {}

interface InputEvent extends Event {
  readonly inputType: string;
  readonly data: string;
}
