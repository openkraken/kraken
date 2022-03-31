import {ClassObject, ClassObjectKind, FunctionObject} from "./declaration";
import _ from "lodash";
import {IDLBlob} from "./IDLBlob";
import {getClassName} from "./utils";
import fs from 'fs';
import path from 'path';
import {generateTypeConverter} from "./generateSource";

export enum TemplateKind {
  globalFunction,
  Dictionary,
  Interface,
  null
}

export function getTemplateKind(object: ClassObject | FunctionObject | null): TemplateKind {
  if (object instanceof FunctionObject) {
    return TemplateKind.globalFunction;
  } else if (object instanceof ClassObject) {
    if (object.kind === ClassObjectKind.dictionary) {
      return TemplateKind.Dictionary;
    }
    return TemplateKind.Interface;
  }
  return TemplateKind.null;
}

function readTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../../static/idl_templates/' + name + '.h.tpl'), {encoding: 'utf-8'});
}

export function generateCppHeader(blob: IDLBlob) {
  const baseTemplate = fs.readFileSync(path.join(__dirname, '../../static/idl_templates/base.h.tpl'), {encoding: 'utf-8'});
  const contents = blob.objects.map(object => {
    const templateKind = getTemplateKind(object);
    if (templateKind === TemplateKind.null) return '';

    switch(templateKind) {
      case TemplateKind.Interface: {
        return _.template(readTemplate('interface'))({
          className: getClassName(blob),
          blob: blob
        });
      }
      case TemplateKind.Dictionary: {
        let props = (object as ClassObject).props;
        return _.template(readTemplate('dictionary'))({
          className: getClassName(blob),
          blob: blob,
          object: object,
          props,
          generateTypeConverter: generateTypeConverter
        });
      }
      case TemplateKind.globalFunction: {
        return _.template(readTemplate('global_function'))({
          className: getClassName(blob),
          blob: blob
        });
      }
    }
  });

  return _.template(baseTemplate)({
    content: contents.join('\n'),
    blob: blob
  });
}
