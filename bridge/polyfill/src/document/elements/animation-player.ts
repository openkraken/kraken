import { Element } from '../element';
import { method } from '../ui-manager';

const animationPlayerBuildInEvents = ['load'];
const animationPlayerBuildInProperties = ['src', 'type'];

export class AnimationPlayerElement extends Element {
  constructor(tagName: string) {
    super(tagName, undefined, animationPlayerBuildInEvents, animationPlayerBuildInProperties);
  }

  play = (name: string, options: any) => {
    const args = [name];
    if (options) args.push(options);

    method(this.nodeId, 'play', args);
  };
}
