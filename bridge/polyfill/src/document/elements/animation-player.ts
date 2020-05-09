import { Element } from '../element';
import { method } from '../ui-manager';

const animationPlayerBuiltInEvents = ['load'];
const animationPlayerBuiltInProperties = ['src', 'type'];

export class AnimationPlayerElement extends Element {
  constructor(tagName: string) {
    super(tagName, undefined, animationPlayerBuiltInEvents, animationPlayerBuiltInProperties);
  }

  play = (name: string, options: any) => {
    const args = [name];
    if (options) args.push(options);

    method(this.targetId, 'play', args);
  };
}
