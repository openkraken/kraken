import {DocumentImpl} from './document';

const _document = new DocumentImpl();

Object.defineProperty(global, 'document', {
  value: _document,
  enumerable: true,
  writable: false,
  configurable: false
});
