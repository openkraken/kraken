/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "blob.h"
#include "foundation/logging.h"

namespace kraken {
namespace binding {

void BlobBuilder::append(JSContext &context, ArrayBuffer &&arrayBuffer) {
  auto data = arrayBuffer.data<uint8_t>(context);
  size_t length = arrayBuffer.size(context);

  for (size_t i = 0; i < length; i++) {
    _data.emplace_back(data[i]);
  }
}

void BlobBuilder::append(JSContext &context, ArrayBufferView &&arrayBufferView) {
  auto data = arrayBufferView.data<uint8_t>(context);
  size_t length = arrayBufferView.size(context);

  for (size_t i = 0; i < length; i++) {
    _data.emplace_back(data[i]);
  }
}

void BlobBuilder::append(JSContext &context, String &&text) {
  std::string str = text.utf8(context);
  std::vector<uint8_t> strArr(str.begin(), str.end());
  _data.reserve(_data.size() + strArr.size());
  _data.insert(_data.end(), strArr.begin(), strArr.end());
}

void BlobBuilder::append(JSContext &context, JSBlob &&blob) {
  std::vector<uint8_t> blobData = blob._data;
  _data.reserve(_data.size() + blobData.size());
  _data.insert(_data.end(), blobData.begin(), blobData.end());
}

void BlobBuilder::append(JSContext &context, Value &value) {
  if (value.isString()) {
    append(context, value.getString(context));
  } else if (value.isObject()) {
    auto obj = value.getObject(context);
    if (obj.isArray(context)) {
      auto arr = obj.getArray(context);
      size_t length = arr.length(context);
      for (size_t i = 0; i < length; i++) {
        Value val = arr.getValueAtIndex(context, i);
        append(context, val);
      }
    } else if (obj.isArrayBuffer(context)) {
      append(context, obj.getArrayBuffer(context));
    } else if (obj.isArrayBufferView(context)) {
      append(context, obj.getArrayBufferView(context));
    }
  }
}

std::vector<uint8_t> BlobBuilder::finalize() {
  return std::move(_data);
}

Value JSBlob::get(JSContext &context, const PropNameID &name) {
  auto _name = name.utf8(context);

  // lower method of new Blob();
  if (_name == "size") {
    return Value((int)size);
  } else if (_name == "type") {
    return String::createFromUtf8(context, mimeType);
  } else if (_name == "slice") {
    return Function::createFromHostFunction(context, PropNameID::forAscii(context, "slice"), 3, slice);
  } else if (_name == "text") {
    return Function::createFromHostFunction(context, PropNameID::forAscii(context, "text"), 0, text);
  } else if (_name == "arrayBuffer") {
    return Function::createFromHostFunction(context, PropNameID::forAscii(context, "arrayBuffer"), 0, arrayBuffer);
  }

  return Value::undefined();
}

void JSBlob::set(JSContext &, const PropNameID &name, const Value &value) {
  // nothing to do
}

std::vector<PropNameID> JSBlob::getPropertyNames(JSContext &context) {
  std::vector<PropNameID> propertyNames;
  // the blob constructor method
  propertyNames.emplace_back(PropNameID::forUtf8(context, "size"));
  propertyNames.emplace_back(PropNameID::forUtf8(context, "type"));
  propertyNames.emplace_back(PropNameID::forUtf8(context, "slice"));
  // TODO stream support
  //  propertyNames.emplace_back(PropNameID::forUtf8(context, "stream"));
  propertyNames.emplace_back(PropNameID::forUtf8(context, "text"));
  propertyNames.emplace_back(PropNameID::forUtf8(context, "arrayBuffer"));
  return propertyNames;
}

Value JSBlob::constructor(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  BlobBuilder builder;

  if (count == 0) {
    return Object::createFromHostObject(context, std::make_shared<JSBlob>(builder.finalize()));
  }

  const Value &array = args[0];
  const Value &options = args[1];

  if (!array.isObject() || !array.getObject(context).isArray(context)) {
    throw JSError(context, "Failed to construct 'Blob': The provided value cannot be converted to a sequence");
  }

  if (options.isUndefined()) {
    Value val = Value(context, array);
    builder.append(context, val);
    return Object::createFromHostObject(context, std::make_shared<JSBlob>(builder.finalize()));
  }

  if (!options.isObject()) {
    throw JSError(context, "Failed to construct 'Blob': parameter 2 ('options') "
                           "is not an object");
  }

  auto mimeType = args[1].getObject(context).getProperty(context, "type").getString(context).utf8(context);
  Value val = Value(context, args[0]);
  builder.append(context, val);
  return Object::createFromHostObject(context, std::make_shared<JSBlob>(builder.finalize(), mimeType));
}

Value JSBlob::slice(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  const Value &startValue = args[0];
  const Value &endValue = args[1];
  const Value &contentTypeValue = args[2];
  std::shared_ptr<JSBlob> blob = thisVal.getObject(context).getHostObject<JSBlob>(context);

  size_t start = 0;
  size_t end = blob->_data.size();
  std::string mimeType = blob->mimeType;

  if (!startValue.isUndefined()) {
    start = startValue.asNumber();
  }

  if (!endValue.isUndefined()) {
    end = endValue.asNumber();
  }

  if (!contentTypeValue.isUndefined()) {
    mimeType = contentTypeValue.getString(context).utf8(context);
  }

  if (start == 0 && end == blob->_data.size()) {
    return Object::createFromHostObject(context, std::make_shared<JSBlob>(blob->_data, mimeType));
  }

  std::vector<uint8_t> newData;
  newData.reserve(blob->_data.size() - (end - start));
  newData.insert(newData.begin(), blob->_data.begin() + start, blob->_data.end() - (blob->_data.size() - end));
  return Object::createFromHostObject(context, std::make_shared<JSBlob>(newData, mimeType));
}

Value JSBlob::text(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  std::shared_ptr<JSBlob> blob = thisVal.getObject(context).getHostObject<JSBlob>(context);
  return String::createFromUtf8(context, blob->_data.data(), blob->_data.size());
}

Value JSBlob::arrayBuffer(JSContext &context, const Value &thisVal, const Value *args, size_t count) {
  std::shared_ptr<JSBlob> blob = thisVal.getObject(context).getHostObject<JSBlob>(context);
  return ArrayBuffer::createWithUnit8(context, blob->_data.data(), blob->_data.size(), [](uint8_t *bytes) {
    // there is no need to collect blob's memory
  });
}

void bindBlob(std::unique_ptr<JSContext> &context) {
  JSA_SET_PROPERTY(*context, context->global(), "__kraken_blob__",
                   Function::createFromHostFunction(*context, PropNameID::forAscii(*context, "__kraken_blob__"), 2,
                                                    JSBlob::constructor));
}

} // namespace binding
} // namespace kraken
