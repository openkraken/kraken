import fs from 'fs';
import {ClassObject, FunctionObject} from "./declaration";

export class IDLBlob {
  raw: string;
  dist: string;
  source: string;
  filename: string;
  implement: string;
  objects: (ClassObject | FunctionObject)[];

  constructor(source: string, dist: string, filename: string, implement: string) {
    this.source = source;
    this.raw = fs.readFileSync(source, {encoding: 'utf-8'});
    this.dist = dist;
    this.filename = filename;
    this.implement = implement;
  }
}
