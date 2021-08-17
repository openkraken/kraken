interface HostObject {}
interface HostClass {}

interface ImageElement extends HostClass {
  width: number;
  height: number;
  naturalWidth: number;
  naturalHeight: number;
  src: string;
  loading: string;
}
