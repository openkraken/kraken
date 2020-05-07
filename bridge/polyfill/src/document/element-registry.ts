import { AudioElement } from './elements/audio';
import { VideoElement } from './elements/video';
import { CanvasElement } from './elements/canvas';
import { ImgElement } from './elements/img';
import { IframeElement } from './elements/iframe';
import { AnimationPlayerElement } from './elements/animation-player';

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
ElementRegistry.define('iframe', IframeElement);
ElementRegistry.define('img', ImgElement);
ElementRegistry.define('animation-player', AnimationPlayerElement);
