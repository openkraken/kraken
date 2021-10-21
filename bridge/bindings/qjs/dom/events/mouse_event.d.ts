interface Event {}
type int64 = number;

interface MouseEvent extends Event {
  readonly clientX: number;
  readonly clientY: number;
  readonly offsetX: number;
  readonly offsetY: number;
}
