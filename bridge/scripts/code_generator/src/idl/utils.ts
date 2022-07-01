import {IDLBlob} from './IDLBlob';
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

export function getClassName(blob: IDLBlob) {
  let raw = camelCase(blob.filename[4].toUpperCase() + blob.filename.slice(5));

  if (raw.slice(0, 4) == 'html') {
    return 'HTML' + raw.slice(4);
  }

  if (raw.slice(0, 3) == 'css') {
    return 'CSS' + raw.slice(3);
  }

  return `${raw[0].toUpperCase() + raw.slice(1)}`;
}

export function getMethodName(name: string) {
  return name[0].toUpperCase() + name.slice(1);
}
