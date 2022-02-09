import {Blob} from './blob';

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
  return `QJS${blob.filename[4].toUpperCase() + blob.filename.slice(5)}`;
}
