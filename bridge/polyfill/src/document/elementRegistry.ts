import { AudioElement } from './elements/audio';
import { VideoElement } from './elements/video';
import { CanvasElement } from './elements/canvas';

const ElementRegistryMap = {};

// TODO: export registry by [window.customElements]
export const ElementRegistry = {
  define(name: string, constructor: any) {
    ElementRegistryMap[name] = constructor;
  },
  get(name: string) {
    return ElementRegistryMap[name];
  },
  // TODO: support while needing it.
  // whenDefined(name: string) {},
};

ElementRegistry.define('audio', AudioElement);
ElementRegistry.define('video', VideoElement);
ElementRegistry.define('canvas', CanvasElement);
