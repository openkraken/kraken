interface Event {}

interface PopStateEvent extends Event {
  readonly state: any;
}
