interface HostObject {}
interface Element {}

interface AnchorElement extends Element {
  href: string;
  target: string;
}
