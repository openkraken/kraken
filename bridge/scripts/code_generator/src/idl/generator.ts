import {IDLBlob} from './IDLBlob';
import {generateCppHeader} from "./generateHeader";
import {generateCppSource} from "./generateSource";

export function generatorSource(blob: IDLBlob) {
  let header = generateCppHeader(blob);
  let source = generateCppSource(blob);
  return {
    header,
    source
  };
}
