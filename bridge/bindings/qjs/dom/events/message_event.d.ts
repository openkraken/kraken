interface Event {}
type int64 = number;

interface MessageEvent extends Event {
  // @ts-ignore
  readonly data: any;
  readonly origin: string;
}
