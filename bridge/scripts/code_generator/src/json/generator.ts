import {JSONBlob} from './JSONBlob';
import {JSONTemplate} from './JSONTemplate';
import _ from 'lodash';

function generateHeader(blob: JSONBlob, template: JSONTemplate): string {
  let compiled = _.template(template.raw);
  return compiled({
    _: _,
    name: blob.filename,
    template_path: blob.source,
    data: blob.json.data
  });
}

function generateBody(blob: JSONBlob, template: JSONTemplate): string {
  let compiled = _.template(template.raw);
  return compiled({
    template_path: blob.source,
    name: blob.filename,
    data: blob.json.data
  });
}

export function generateJSONTemplate(blob: JSONBlob, headerTemplate: JSONTemplate, bodyTemplate?: JSONTemplate) {
  let header = generateHeader(blob, headerTemplate);
  let body = bodyTemplate ? generateBody(blob, bodyTemplate) : '';

  return {
    header: header,
    source: body,
  };
}
