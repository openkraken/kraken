import { Element } from '../element';
import { method } from '../ui-manager';

const animationPlayerBuiltInEvents = ['load', 'error'];
const animationPlayerBuiltInProperties = ['src', 'type'];

export class AnimationPlayerElement extends Element {
  constructor() {
    super('animation-player', undefined, animationPlayerBuiltInEvents, animationPlayerBuiltInProperties);
  }

  play = (name: string, options: any) => {
    const args = [name];
    if (options) args.push(options);

    method(this.targetId, 'play', args);
  };
}
