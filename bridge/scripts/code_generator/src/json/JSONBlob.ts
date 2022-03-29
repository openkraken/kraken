import {ClassObject, FunctionObject} from "../idl/declaration";
import fs from "fs";

export class JSONBlob {
  raw: string;
  dist: string;
  source: string;
  filename: string;
  json: any;

  constructor(source: string, dist: string, filename: string) {
    this.source = source;
    this.raw = fs.readFileSync(source, {encoding: 'utf-8'});
    this.dist = dist;
    this.filename = filename;
    this.json = JSON.parse(this.raw);
  }
}
