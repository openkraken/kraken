import { Element } from '../element';

const anchorBuildInProperties: string[] = ['href', 'target'];
const anchorBuiltInEvents: string[] = [];

export class AnchorElement extends Element {
  constructor() {
    super('a', undefined, anchorBuiltInEvents, anchorBuildInProperties);
  }
}
