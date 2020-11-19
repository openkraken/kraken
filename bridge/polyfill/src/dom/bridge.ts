import { KrakenBlob } from "../bridge";

declare const __kraken_request_batch_update__: (fn: () => void) => void;
export const krakenRequestBatchUpdate = __kraken_request_batch_update__;

declare const __kraken_ui_manager__: (message: string) => string;
export const krakenUIManager = __kraken_ui_manager__;

declare const __kraken_ui_listener__: (fn: (message: string) => void) => void;
export const addKrakenUIListener = __kraken_ui_listener__;

declare const __kraken_to_blob__: (targetId: number, devicePixelRatio: number, callback: (err: string, blob: Blob) => void) => KrakenBlob;
export const krakenToBlob = __kraken_to_blob__;

declare const __kraken_request_animation_frame__: (callback: (timeStamp: DOMHighResTimeStamp) => void) => number;
export const krakenRequestAnimationFrame = __kraken_request_animation_frame__;
