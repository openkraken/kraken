interface HostObject {}
interface HostClass {}

interface ObjectElement extends HostClass {
  type: string;
  data: string;
  currentData: string;
  currentType: string;
}
