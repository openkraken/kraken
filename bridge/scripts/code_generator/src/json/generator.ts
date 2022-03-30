import {JSONBlob} from './JSONBlob';
import {Template} from './template';
import _ from 'lodash';

function generateHeader(blob: JSONBlob, template: Template): string {
  let compiled = _.template(template.raw);
  return compiled({
    _: _,
    name: blob.filename,
    template_path: blob.source,
    data: blob.json.data
  });
}

function generateBody(blob: JSONBlob, template: Template): string {
  let compiled = _.template(template.raw);
  return compiled({
    template_path: blob.source,
    name: blob.filename,
    data: blob.json.data
  });
}

export function generateJSONTemplate(blob: JSONBlob, headerTemplate: Template, bodyTemplate?: Template) {
  let header = generateHeader(blob, headerTemplate);
  let body = bodyTemplate ? generateBody(blob, bodyTemplate) : '';

  return {
    header: header,
    source: body,
  };
}
