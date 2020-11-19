import { krakenRequestAnimationFrame } from './bridge';
import { requestUpdateFrame } from './ui-manager';

// Clear all pending frames to keep execution order.
export function requestAnimationFrame(callback: any) {
  requestUpdateFrame();
  return krakenRequestAnimationFrame(callback);
}

// @TODO: clearAnimationFrame
// export function clearAnimationFrame(id: number) {}
