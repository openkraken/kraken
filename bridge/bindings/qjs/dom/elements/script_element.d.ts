interface HostObject {}
interface Element {}

interface ScriptElement extends Element {
  src: string;
  async: boolean;
  defer: boolean;
  type: string;
  charset: string;
  text: string;
}
