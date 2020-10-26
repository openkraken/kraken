export interface KrakenLocation {
  reload: () => void;
  href: string;
}

export interface KrakenWindow {
  onLoad: any;
  onColorSchemeChange: any;
  devicePixelRatio: number;
  colorScheme: string;
  location: KrakenLocation;
  parent: any;
}

export interface KrakenBlob {
  size: number;
  type: string;
  slice(start?: number, end?: number, contentType?: string): KrakenBlob;
  text(): string;
  arrayBuffer(): ArrayBuffer;
}

export interface PrivateKraken {
  appName: string;
  appVersion: string;
  platform: string;
  product: string;
  productSub: string;
  comment: string;
  userAgent: string;
}

declare const __kraken_window__: KrakenWindow;
export const krakenWindow = __kraken_window__;

declare const __kraken_print__: (log: string, level?: string) => void;
export const krakenPrint = __kraken_print__;
