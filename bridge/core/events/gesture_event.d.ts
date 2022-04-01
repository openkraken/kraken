interface GestureEvent extends Event {
  readonly state: string;
  readonly direction: string;
  readonly deltaX: number;
  readonly deltaY: number;
  readonly velocityX: number;
  readonly velocityY: number;
  readonly scale: number;
  readonly rotation: number;
}
