import { Element } from '../element';
import { method } from '../UIManager';

export class AnimationPlayerElement extends Element {
  constructor(tagName: string) {
    super(tagName);
  }

  set src(value: string) {
    this.setAttribute('src', value);
  }

  get src() {
    return this.getAttribute('src');
  }

  set type(value: string) {
    this.setAttribute('type', value);
  }

  get type() {
    return this.getAttribute('type');
  }

  play = (name: string, options: any) => {
    const args = [name];
    if (options) args.push(options);

    method(this.nodeId, 'play', args);
  };
}
