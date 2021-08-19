interface HostObject {}
interface Element {}

interface ImageElement extends Element {
  width: number;
  height: number;
  readonly naturalWidth: number;
  readonly naturalHeight: number;
  src: string;
  loading: string;
}
