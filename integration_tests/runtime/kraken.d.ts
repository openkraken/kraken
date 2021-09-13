type MethodHandler = (method: string, args: any[]) => void;
interface MethodChannel {
    addMethodCallHandler(handler: MethodHandler): void;
    removeMethodCallHandler(handler: MethodHandler): void;
    invokeMethod(method: string, ...args: any[]): Promise<string>
}

interface Kraken {
    methodChannel: MethodChannel;
}

declare const kraken: Kraken;

interface Connection {
  isConnected: boolean;
  type: string;
}

interface DeviceInfo {
  brand: string;
  isPhysicalDevice: boolean;
  platformName: string;
}

declare enum PointerChange {
  cancel,
  add,
  remove,
  hover,
  down,
  move,
  up
}

type SimulatePointer = (list: [number, number, number][], pointer: number) => void;
type SimulateInputText = (chars: string) => void;
declare const simulatePointer: SimulatePointer;
declare const simulateInputText: SimulateInputText;

interface Navigator {
  connection: {
    getConnectivity(): Connection;
  }
  getDeviceInfo(): DeviceInfo;
}

interface HTMLDivElement {
    toBlob(devicePixelRatio: number): Promise<Blob>;
}

interface HTMLCanvasElement {
    toBlob(devicePixcelRatio: number): Promise<Blob>;
}

interface HTMLMediaElement {
  /**
   * The HTMLMediaElement.fastSeek() method quickly seeks the media to the new time with precision tradeoff.
   * @param time A double.
   */
  fastSeek(time: number): void;
}

interface HTMLElement {
    toBlob(devicePixcelRatio: number): Promise<Blob>;
}

/**
 * The mocked local http server origin.
 */
declare const LOCAL_HTTP_SERVER :string;
