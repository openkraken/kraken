import {Blob} from './blob';
import {camelCase} from 'lodash';

export function addIndent(str: String, space: number) {
  let lines = str.split('\n');
  lines = lines.map(l => {
    for (let i = 0; i < space; i ++) {
      l = ' ' + l;
    }
    return l;
  });
  return lines.join('\n');
}

export function getClassName(blob: Blob) {
  let raw = camelCase(blob.filename[4].toUpperCase() + blob.filename.slice(5));

  return `${raw[0].toUpperCase() + raw.slice(1)}`;
}
