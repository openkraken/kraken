import { AudioElement } from './elements/audio';
import { VideoElement } from './elements/video';
import { CanvasElement } from './elements/canvas';
import { ImageElement } from './elements/img';
import { IframeElement } from './elements/iframe';
import { AnimationPlayerElement } from './elements/animation-player';
import { AnchorElement } from "./elements/anchor";

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
ElementRegistry.define('img', ImageElement);
ElementRegistry.define('a', AnchorElement);
ElementRegistry.define('animation-player', AnimationPlayerElement);
