interface Event {}

interface IntersectionChangeEvent extends Event {
  readonly intersectionRatio: number;
}
