interface Event {}
type int64 = number;

interface MediaErrorEvent extends Event {
  readonly code: int64;
  readonly message: string;
}
