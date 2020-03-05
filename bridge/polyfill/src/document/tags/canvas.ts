import { Element } from '../element';
import { method } from '../UIManager';

export class CanvasElement extends Element {
  constructor(tagName: string) {
    super(tagName);
  }

  play() {
    method(this.nodeId, 'play');
  }

  pause() {
    method(this.nodeId, 'pause');
  }

  fastSeek = (duration: number) => {
    method(this.nodeId, 'fastSeek', [duration]);
  };

  set src(value: string) {
    this.setAttribute('src', value);
  }
  get src() {
    return this.getAttribute('src');
  }

  set autoplay(value: any) {
    this.setAttribute('autoplay', value);
  }
  get autoplay() {
    return this.getAttribute('autoplay');
  }

  set loop(value: any) {
    this.setAttribute('loop', value);
  }
  get loop() {
    return this.getAttribute('loop');
  }

  set poster(value: any) {
    this.setAttribute('poster', value);
  }
  get poster() {
    return this.getAttribute('poster');
  }

  getContext(contextType: string) {
    if (contextType === '2d') {
      return new _CanvasRenderingContext2D(this);
    } else {
      throw new TypeError(`Canvas not support context type of ${contextType}.`);
    }
  }
}

const UPDATE_CANVAS_CONTEXT_2D = 'updateContext2DProperty';
const PROPERTIES = [
  'fillStyle',
];
const METHODS = [];

class _CanvasRenderingContext2D implements CanvasRenderingContext2D {
  globalAlpha: number;
  globalCompositeOperation: string;
  drawImage(image: CanvasImageSource, dx: number, dy: number): void;
  drawImage(image: CanvasImageSource, dx: number, dy: number, dw: number, dh: number): void;
  drawImage(image: CanvasImageSource, sx: number, sy: number, sw: number, sh: number, dx: number, dy: number, dw: number, dh: number): void;
  drawImage(image: any, sx: any, sy: any, sw?: any, sh?: any, dx?: any, dy?: any, dw?: any, dh?: any) {
    throw new Error("Method not implemented.");
  }
  beginPath(): void {
    throw new Error("Method not implemented.");
  }
  clip(fillRule?: CanvasFillRule): void;
  clip(path: Path2D, fillRule?: CanvasFillRule): void;
  clip(path?: any, fillRule?: any) {
    throw new Error("Method not implemented.");
  }
  fill(fillRule?: CanvasFillRule): void;
  fill(path: Path2D, fillRule?: CanvasFillRule): void;
  fill(path?: any, fillRule?: any) {
    throw new Error("Method not implemented.");
  }
  isPointInPath(x: number, y: number, fillRule?: CanvasFillRule): boolean;
  isPointInPath(path: Path2D, x: number, y: number, fillRule?: CanvasFillRule): boolean;
  isPointInPath(path: any, x: any, y?: any, fillRule?: any) {
    throw new Error("Method not implemented.");
  }
  isPointInStroke(x: number, y: number): boolean;
  isPointInStroke(path: Path2D, x: number, y: number): boolean;
  isPointInStroke(path: any, x: any, y?: any) {
    throw new Error("Method not implemented.");
  }
  stroke(): void;
  stroke(path: Path2D): void;
  stroke(path?: any) {
    throw new Error("Method not implemented.");
  }

  strokeStyle: string | CanvasGradient | CanvasPattern;
  createLinearGradient(x0: number, y0: number, x1: number, y1: number): CanvasGradient {
    throw new Error("Method not implemented.");
  }
  createPattern(image: CanvasImageSource, repetition: string): CanvasPattern {
    throw new Error("Method not implemented.");
  }
  createRadialGradient(x0: number, y0: number, r0: number, x1: number, y1: number, r1: number): CanvasGradient {
    throw new Error("Method not implemented.");
  }
  filter: string;
  imageSmoothingEnabled: boolean;
  imageSmoothingQuality: ImageSmoothingQuality;
  arc(x: number, y: number, radius: number, startAngle: number, endAngle: number, anticlockwise?: boolean): void {
    throw new Error("Method not implemented.");
  }
  arcTo(x1: number, y1: number, x2: number, y2: number, radius: number): void {
    throw new Error("Method not implemented.");
  }
  bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number): void {
    throw new Error("Method not implemented.");
  }
  closePath(): void {
    throw new Error("Method not implemented.");
  }
  ellipse(x: number, y: number, radiusX: number, radiusY: number, rotation: number, startAngle: number, endAngle: number, anticlockwise?: boolean): void {
    throw new Error("Method not implemented.");
  }
  lineTo(x: number, y: number): void {
    throw new Error("Method not implemented.");
  }
  moveTo(x: number, y: number): void {
    throw new Error("Method not implemented.");
  }
  quadraticCurveTo(cpx: number, cpy: number, x: number, y: number): void {
    throw new Error("Method not implemented.");
  }
  rect(x: number, y: number, w: number, h: number): void {
    throw new Error("Method not implemented.");
  }
  lineCap: CanvasLineCap;
  lineDashOffset: number;
  lineJoin: CanvasLineJoin;
  lineWidth: number;
  miterLimit: number;
  getLineDash(): number[] {
    throw new Error("Method not implemented.");
  }
  setLineDash(segments: number[]): void;
  setLineDash(segments: Iterable<number>): void;
  setLineDash(segments: any) {
    throw new Error("Method not implemented.");
  }
  clearRect(x: number, y: number, w: number, h: number): void {
    throw new Error("Method not implemented.");
  }
  fillRect(x: number, y: number, w: number, h: number): void {
    throw new Error("Method not implemented.");
  }
  strokeRect(x: number, y: number, w: number, h: number): void {
    throw new Error("Method not implemented.");
  }
  shadowBlur: number;
  shadowColor: string;
  shadowOffsetX: number;
  shadowOffsetY: number;
  restore(): void {
    throw new Error("Method not implemented.");
  }
  save(): void {
    throw new Error("Method not implemented.");
  }
  fillText(text: string, x: number, y: number, maxWidth?: number): void {
    throw new Error("Method not implemented.");
  }
  measureText(text: string): TextMetrics {
    throw new Error("Method not implemented.");
  }
  strokeText(text: string, x: number, y: number, maxWidth?: number): void {
    throw new Error("Method not implemented.");
  }
  direction: CanvasDirection;
  font: string;
  textAlign: CanvasTextAlign;
  textBaseline: CanvasTextBaseline;
  getTransform(): DOMMatrix {
    throw new Error("Method not implemented.");
  }
  resetTransform(): void {
    throw new Error("Method not implemented.");
  }
  rotate(angle: number): void {
    throw new Error("Method not implemented.");
  }
  scale(x: number, y: number): void {
    throw new Error("Method not implemented.");
  }
  setTransform(a: number, b: number, c: number, d: number, e: number, f: number): void;
  setTransform(transform?: DOMMatrix2DInit): void;
  setTransform(a?: any, b?: any, c?: any, d?: any, e?: any, f?: any) {
    throw new Error("Method not implemented.");
  }
  transform(a: number, b: number, c: number, d: number, e: number, f: number): void {
    throw new Error("Method not implemented.");
  }
  translate(x: number, y: number): void {
    throw new Error("Method not implemented.");
  }
  drawFocusIfNeeded(element: Element): void;
  drawFocusIfNeeded(path: Path2D, element: Element): void;
  drawFocusIfNeeded(path: any, element?: any) {
    throw new Error("Method not implemented.");
  }
  scrollPathIntoView(): void;
  scrollPathIntoView(path: Path2D): void;
  scrollPathIntoView(path?: any) {
    throw new Error("Method not implemented.");
  }

  readonly canvas;
  constructor(canvas: CanvasElement) {
    this.canvas = canvas;
  }

}

