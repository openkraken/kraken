interface HostObject {}
interface HostClass {}

interface CanvasRenderingContext2D extends HostObject {
  fillStyle: string;
  direction: string;
  font: string;
  strokeStyle: string;
  lineCap: string;
  lineDashOffset: string;
  lineJoin: string;
  lineWidth: string;
  miterLimit: string;
  textAlign: string;
  textBaseline: string;
  arc(x: number, y: number, radius: number, startAngle: number, endAngle: number, anticlockwise?: boolean): void;
  arcTo(x1: number, y1: number, x2: number, y2: number, radius: number): void;
  beginPath(): void;
  bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number): void;
  clearRect(x: number, y: number, w: number, h: number): void;
  closePath(): void;
  clip(path: string): void;
  drawImage(image: CanvasImageSource, sx: number, sy: number, sw: number, sh: number, dx: number, dy: number, dw: number, dh: number): void;
  drawImage(image: CanvasImageSource, dx: number, dy: number, dw: number, dh: number): void;
  drawImage(image: CanvasImageSource, dx: number, dy: number): void;
  ellipse(x: number, y: number, radiusX: number, radiusY: number, rotation: number, startAngle: number, endAngle: number, anticlockwise?: boolean): void;
  fill(path: string): void;
  fillRect(x: number, y: number, w: number, h: number): void;
  fillText(text: string, x: number, y: number, maxWidth?: number): void;
  lineTo(x: number, y: number): void;
  moveTo(x: number, y: number): void;
  rect(x: number, y: number, w: number, h: number): void;
  restore(): void;
  resetTransform(): void;
  rotate(angle: number): void;
  quadraticCurveTo(cpx: number, cpy: number, x: number, y: number): void;
  stroke(): void;
  strokeRect(x: number, y: number, w: number, h: number): void;
  save(): void;
  scale(x: number, y: number): void;
  strokeText(text: string, x: number, y: number, maxWidth?: number): void;
  setTransform(a: number, b: number, c: number, d: number, e: number, f: number): void;
  transform(a: number, b: number, c: number, d: number, e: number, f: number): void;
  translate(x: number, y: number): void;
}

interface CanvasElement extends HostClass {
  width: string;
  height: string;
  getContext: (contextType: string) => CanvasRenderingContext2D;
}
