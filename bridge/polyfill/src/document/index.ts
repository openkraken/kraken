
import './UIListener';
import { document } from './document';

Object.defineProperty(global, 'document', {
  value: document,
  enumerable: true,
  writable: false,
  configurable: false
});
