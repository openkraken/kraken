import {Blob} from './blob';
import {generateCppHeader} from "./generate_header";
import {generateCppSource} from "./genereate_source";

export function generatorSource(blob: Blob) {
  let header = generateCppHeader(blob);
  let source = generateCppSource(blob);
  return {
    header,
    source
  };
}
