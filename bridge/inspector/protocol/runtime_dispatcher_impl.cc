/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#include "inspector/protocol/runtime_dispatcher_impl.h"

namespace kraken {
namespace debugger {

bool RuntimeDispatcherImpl::canDispatch(const std::string &method) {
  return m_dispatchMap.find(method) != m_dispatchMap.end();
}

void RuntimeDispatcherImpl::dispatch(uint64_t callId, const std::string &method,
                                     kraken::debugger::JSONObject message) {
  std::unordered_map<std::string, CallHandler>::iterator it = m_dispatchMap.find(method);
  if (it == m_dispatchMap.end()) {
    return;
  }
  ErrorSupport errors;
  (it->second)(callId, method, std::move(message), &errors);
}

/////////////  COMMANDS  //////////////////////

void RuntimeDispatcherImpl::enable(uint64_t callId, const std::string &method, JSONObject message,
                                   ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->enable();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void RuntimeDispatcherImpl::disable(uint64_t callId, const std::string &method, JSONObject message,
                                    ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->disable();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void RuntimeDispatcherImpl::awaitPromise(uint64_t callId, const std::string &method, JSONObject message,
                                         ErrorSupport *) {}

class CallFunctionOnCallbackImpl : public RuntimeBackend::CallFunctionOnCallback, public DispatcherBase::Callback {
public:
  CallFunctionOnCallbackImpl(std::unique_ptr<DispatcherBase::WeakPtr> backendImpl, uint64_t callId,
                             const std::string &method, kraken::debugger::JSONObject message,
                             rapidjson::Document::AllocatorType &allocator)
    : DispatcherBase::Callback(std::move(backendImpl), callId, method, std::move(message)), m_allocator(allocator) {}

  void sendSuccess(std::unique_ptr<kraken::debugger::RemoteObject> result,
                   Maybe<kraken::debugger::ExceptionDetails> exceptionDetails) override {
    rapidjson::Value resultObject(rapidjson::kObjectType);
    resultObject.AddMember("result", result.get()->toValue(m_allocator), m_allocator);
    if (exceptionDetails.isJust()) {
      resultObject.AddMember("exceptionDetails", exceptionDetails.fromJust()->toValue(m_allocator), m_allocator);
    }
    sendIfActive(std::move(resultObject), DispatchResponse::OK());
  }

  void fallThrough() override {
    fallThroughIfActive();
  }

  void sendFailure(const DispatchResponse &response) override {
    //                DCHECK(response.status() == DispatchResponse::kError);
    sendIfActive(rapidjson::Value(rapidjson::kObjectType), response);
  }

private:
  rapidjson::Document::AllocatorType &m_allocator;
};

void RuntimeDispatcherImpl::callFunctionOn(uint64_t callId, const std::string &method, JSONObject message,
                                           ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::string in_functionDeclaration = "";
  if (message.HasMember("functionDeclaration") && message["functionDeclaration"].IsString()) {
    in_functionDeclaration = message["functionDeclaration"].GetString();
  } else {
    errors->setName("functionDeclaration");
    errors->addError("functionDeclaration should be string");
  }

  Maybe<std::string> in_objectId;
  if (message.HasMember("objectId")) {
    if (message["objectId"].IsString()) {
      in_objectId = message["objectId"].GetString();
    } else {
      errors->setName("objectId");
      errors->addError("objectId should be string");
    }
  }

  Maybe<std::vector<std::unique_ptr<debugger::CallArgument>>> in_arguments;
  if (message.HasMember("arguments") && message["arguments"].IsArray()) {
    in_arguments = std::make_unique<std::vector<std::unique_ptr<debugger::CallArgument>>>();
    auto array = message["arguments"].GetArray();
    for (auto &item : array) {
      std::unique_ptr<debugger::CallArgument> argument = debugger::CallArgument::fromValue(&item, errors);
      in_arguments.fromJust()->emplace_back(std::move(argument));
    }
  } else {
    errors->setName("arguments");
    errors->addError("arguments not found");
  }

  Maybe<bool> in_silent;
  if (message.HasMember("silent")) {
    if (message["silent"].IsBool()) {
      in_silent = message["silent"].GetBool();
    } else {
      errors->setName("silent");
      errors->addError("silent should be bool");
    }
  }

  Maybe<bool> in_returnByValue;
  if (message.HasMember("returnByValue")) {
    if (message["returnByValue"].IsBool()) {
      in_returnByValue = message["returnByValue"].GetBool();
    } else {
      errors->setName("returnByValue");
      errors->addError("returnByValue should be bool");
    }
  }

  Maybe<bool> in_generatePreview;
  if (message.HasMember("generatePreview")) {
    if (message["generatePreview"].IsBool()) {
      in_generatePreview = message["generatePreview"].GetBool();
    } else {
      errors->setName("generatePreview");
      errors->addError("generatePreview should be bool");
    }
  }

  Maybe<bool> in_userGesture;
  if (message.HasMember("userGesture")) {
    if (message["userGesture"].IsBool()) {
      in_userGesture = message["userGesture"].GetBool();
    } else {
      errors->setName("userGesture");
      errors->addError("userGesture should be bool");
    }
  }

  Maybe<bool> in_awaitPromise;
  if (message.HasMember("awaitPromise")) {
    if (message["awaitPromise"].IsBool()) {
      in_awaitPromise = message["awaitPromise"].GetBool();
    } else {
      errors->setName("awaitPromise");
      errors->addError("awaitPromise should be bool");
    }
  }

  Maybe<int> in_executionContextId;
  if (message.HasMember("executionContextId")) {
    if (message["executionContextId"].IsInt()) {
      in_executionContextId = message["executionContextId"].GetInt();
    } else {
      errors->setName("executionContextId");
      errors->addError("executionContextId should be bool");
    }
  }

  Maybe<std::string> in_objectGroup;
  if (message.HasMember("objectGroup")) {
    if (message["objectGroup"].IsString()) {
      in_objectGroup = message["objectGroup"].GetString();
    } else {
      errors->setName("objectGroup");
      errors->addError("objectGroup should be bool");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  std::unique_ptr<CallFunctionOnCallbackImpl> callback(
    new CallFunctionOnCallbackImpl(weakPtr(), callId, method, std::move(message), m_json_doc.GetAllocator()));
  m_backend->callFunctionOn(in_functionDeclaration, std::move(in_objectId), std::move(in_arguments),
                            std::move(in_silent), std::move(in_returnByValue), std::move(in_generatePreview),
                            std::move(in_userGesture), std::move(in_awaitPromise), std::move(in_executionContextId),
                            std::move(in_objectGroup), std::move(callback));
  return;
}

void RuntimeDispatcherImpl::compileScript(uint64_t callId, const std::string &method, JSONObject message,
                                          ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::string in_expression = "";
  if (message.HasMember("expression") && message["expression"].IsString()) {
    in_expression = message["expression"].GetString();
  } else {
    errors->setName("expression");
    errors->addError("expression should be string");
  }

  std::string in_sourceURL = "";
  if (message.HasMember("sourceURL") && message["sourceURL"].IsString()) {
    in_sourceURL = message["sourceURL"].GetString();
  } else {
    errors->setName("sourceURL");
    errors->addError("sourceURL should be string");
  }

  bool in_persistScript = false;
  if (message.HasMember("persistScript") && message["persistScript"].IsBool()) {
    in_persistScript = message["persistScript"].GetBool();
  } else {
    errors->setName("persistScript");
    errors->addError("persistScript should be bool");
  }

  Maybe<int> in_executionContextId;
  if (message.HasMember("executionContextId")) {
    if (message["executionContextId"].IsInt()) {
      in_executionContextId = message["executionContextId"].GetInt();
    } else {
      errors->setName("executionContextId");
      errors->addError("executionContextId should be int");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  // Declare output parameters.
  Maybe<std::string> out_scriptId;
  Maybe<ExceptionDetails> out_exceptionDetails;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response =
    m_backend->compileScript(in_expression, in_sourceURL, in_persistScript, std::move(in_executionContextId),
                             &out_scriptId, &out_exceptionDetails);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }

  rapidjson::Value result(rapidjson::kObjectType);
  if (response.status() == DispatchResponse::kSuccess) {
    if (out_scriptId.isJust()) {
      result.AddMember("scriptId", out_scriptId.fromJust(), m_json_doc.GetAllocator());
    }
    if (out_exceptionDetails.isJust()) {
      result.AddMember("exceptionDetails", out_exceptionDetails.fromJust()->toValue(m_json_doc.GetAllocator()),
                       m_json_doc.GetAllocator());
    }
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

void RuntimeDispatcherImpl::discardConsoleEntries(uint64_t callId, const std::string &method,
                                                  JSONObject message, ErrorSupport *) {}

class EvaluateCallbackImpl : public RuntimeBackend::EvaluateCallback, public DispatcherBase::Callback {
public:
  EvaluateCallbackImpl(std::unique_ptr<DispatcherBase::WeakPtr> backendImpl, uint64_t callId, const std::string &method,
                       kraken::debugger::JSONObject message, rapidjson::Document::AllocatorType &allocator)
    : DispatcherBase::Callback(std::move(backendImpl), callId, method, std::move(message)), m_allocator(allocator) {}

  void sendSuccess(std::unique_ptr<debugger::RemoteObject> result,
                   Maybe<debugger::ExceptionDetails> exceptionDetails) override {
    rapidjson::Value resultObject(rapidjson::kObjectType);
    resultObject.AddMember("result", result->toValue(m_allocator), m_allocator);
    if (exceptionDetails.isJust())
      resultObject.AddMember("exceptionDetails", exceptionDetails.fromJust()->toValue(m_allocator), m_allocator);
    sendIfActive(std::move(resultObject), DispatchResponse::OK());
  }

  void fallThrough() override {
    fallThroughIfActive();
  }

  void sendFailure(const DispatchResponse &response) override {
    //                DCHECK(response.status() == DispatchResponse::kError);
    sendIfActive(rapidjson::Value(rapidjson::kObjectType), response);
  }

private:
  rapidjson::Document::AllocatorType &m_allocator;
};

void RuntimeDispatcherImpl::evaluate(uint64_t callId, const std::string &method, JSONObject message,
                                     ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();

  std::string in_expression = "";
  if (message.HasMember("expression") && message["expression"].IsString()) {
    in_expression = message["expression"].GetString();
  } else {
    errors->setName("expression");
    errors->addError("expression should be string");
  }

  Maybe<std::string> in_objectGroup;
  if (message.HasMember("objectGroup")) {
    if (message["objectGroup"].IsString()) {
      in_objectGroup = message["objectGroup"].GetString();
    } else {
      errors->setName("objectGroup");
      errors->addError("objectGroup should be string");
    }
  }

  Maybe<bool> in_includeCommandLineAPI;
  if (message.HasMember("includeCommandLineAPI")) {
    if (message["includeCommandLineAPI"].IsBool()) {
      in_includeCommandLineAPI = message["includeCommandLineAPI"].GetBool();
    } else {
      errors->setName("includeCommandLineAPI");
      errors->addError("includeCommandLineAPI should be bool");
    }
  }

  Maybe<bool> in_silent;
  if (message.HasMember("silent")) {
    if (message["silent"].IsBool()) {
      in_silent = message["silent"].GetBool();
    } else {
      errors->setName("silent");
      errors->addError("silent should be bool");
    }
  }

  Maybe<int> in_contextId;
  if (message.HasMember("contextId")) {
    if (message["contextId"].IsInt()) {
      in_contextId = message["contextId"].GetInt();
    } else {
      errors->setName("contextId");
      errors->addError("contextId should be int");
    }
  }

  Maybe<bool> in_returnByValue;
  if (message.HasMember("returnByValue")) {
    if (message["returnByValue"].IsBool()) {
      in_returnByValue = message["returnByValue"].GetBool();
    } else {
      errors->setName("returnByValue");
      errors->addError("returnByValue should be bool");
    }
  }

  Maybe<bool> in_generatePreview;
  if (message.HasMember("generatePreview")) {
    if (message["generatePreview"].IsBool()) {
      in_generatePreview = message["generatePreview"].GetBool();
    } else {
      errors->setName("generatePreview");
      errors->addError("generatePreview should be bool");
    }
  }

  Maybe<bool> in_userGesture;
  if (message.HasMember("userGesture")) {
    if (message["userGesture"].IsBool()) {
      in_userGesture = message["userGesture"].GetBool();
    } else {
      errors->setName("userGesture");
      errors->addError("userGesture should be bool");
    }
  }

  Maybe<bool> in_awaitPromise;
  if (message.HasMember("awaitPromise")) {
    if (message["awaitPromise"].IsBool()) {
      in_awaitPromise = message["awaitPromise"].GetBool();
    } else {
      errors->setName("awaitPromise");
      errors->addError("awaitPromise should be bool");
    }
  }

  Maybe<bool> in_throwOnSideEffect;
  if (message.HasMember("throwOnSideEffect")) {
    if (message["throwOnSideEffect"].IsBool()) {
      in_throwOnSideEffect = message["throwOnSideEffect"].GetBool();
    } else {
      errors->setName("throwOnSideEffect");
      errors->addError("throwOnSideEffect should be bool");
    }
  }

  Maybe<double> in_timeout;
  if (message.HasMember("timeout")) {
    if (message["timeout"].IsDouble()) {
      in_timeout = message["timeout"].GetDouble();
    } else {
      errors->setName("timeout");
      errors->addError("timeout should be double");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  std::unique_ptr<EvaluateCallbackImpl> callback(
    new EvaluateCallbackImpl(weakPtr(), callId, method, std::move(message), m_json_doc.GetAllocator()));
  m_backend->evaluate(in_expression, std::move(in_objectGroup), std::move(in_includeCommandLineAPI),
                      std::move(in_silent), std::move(in_contextId), std::move(in_returnByValue),
                      std::move(in_generatePreview), std::move(in_userGesture), std::move(in_awaitPromise),
                      std::move(in_throwOnSideEffect), std::move(in_timeout), std::move(callback));
  return;
}

void RuntimeDispatcherImpl::getIsolateId(uint64_t callId, const std::string &method, JSONObject message,
                                         ErrorSupport *) {
  // Declare output parameters.
  std::string out_id;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->getIsolateId(&out_id);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }

  rapidjson::Value result(rapidjson::kObjectType);
  if (response.status() == DispatchResponse::kSuccess) {
    result.AddMember("id", out_id, m_json_doc.GetAllocator());
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

void RuntimeDispatcherImpl::getHeapUsage(uint64_t callId, const std::string &method, JSONObject message,
                                         ErrorSupport *) {
  // Declare output parameters.
  double out_usedSize;
  double out_totalSize;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->getHeapUsage(&out_usedSize, &out_totalSize);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  rapidjson::Value result(rapidjson::kObjectType);
  if (response.status() == DispatchResponse::kSuccess) {
    result.AddMember("usedSize", out_usedSize, m_json_doc.GetAllocator());
    result.AddMember("totalSize", out_totalSize, m_json_doc.GetAllocator());
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

/**
 * Returns properties of a given object. Object group of the result is inherited from the target object.
 *
 * @param objectId Identifier of the object to return properties for.
 * @param ownProperties If true, returns properties belonging only to the element itself, not to its prototype chain.
 * @param accessorPropertiesOnly If true, returns accessor properties (with getter/setter) only; internal properties are
 * not returned either.
 * @param generatePreview Whether preview should be generated for the results.
 *
 * @return
 *      - result: Object properties.
 *      - internalProperties: Internal object properties (only of the element itself).
 *      - privateProperties: Object private properties.
 *      - exceptionDetails
 * */
void RuntimeDispatcherImpl::getProperties(uint64_t callId, const std::string &method, JSONObject message,
                                          ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  std::string in_objectId = "";
  if (message.HasMember("objectId") && message["objectId"].IsString()) {
    in_objectId = message["objectId"].GetString();
  } else {
    errors->setName("objectId");
    errors->addError("objectId not found");
  }

  Maybe<bool> in_ownProperties;
  if (message.HasMember("ownProperties")) {
    errors->setName("ownProperties");
    if (message["ownProperties"].IsBool()) {
      in_ownProperties = message["ownProperties"].GetBool();
    } else {
      errors->addError("ownProperties should be bool");
    }
  }

  Maybe<bool> in_accessorPropertiesOnly;
  if (message.HasMember("accessorPropertiesOnly")) {
    errors->setName("accessorPropertiesOnly");
    if (message["accessorPropertiesOnly"].IsBool()) {
      in_accessorPropertiesOnly = message["accessorPropertiesOnly"].GetBool();
    } else {
      errors->addError("accessorPropertiesOnly should be bool");
    }
  }

  Maybe<bool> in_generatePreview;
  if (message.HasMember("generatePreview")) {
    errors->setName("generatePreview");
    if (message["generatePreview"].IsBool()) {
      in_generatePreview = message["generatePreview"].GetBool();
    } else {
      errors->addError("generatePreview should be bool");
    }
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  // Declare output parameters.
  std::unique_ptr<std::vector<std::unique_ptr<PropertyDescriptor>>> out_result;
  Maybe<std::vector<std::unique_ptr<InternalPropertyDescriptor>>> out_internalProperties;
  Maybe<std::vector<std::unique_ptr<PrivatePropertyDescriptor>>> out_privateProperties;
  Maybe<ExceptionDetails> out_exceptionDetails;

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->getProperties(
    in_objectId, std::move(in_ownProperties), std::move(in_accessorPropertiesOnly), std::move(in_generatePreview),
    &out_result, &out_internalProperties, &out_privateProperties, &out_exceptionDetails);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }

  rapidjson::Value result(rapidjson::kObjectType);
  result.SetObject();

  if (response.status() == DispatchResponse::kSuccess) {
    rapidjson::Value _result(rapidjson::kArrayType);
    for (const auto &propertyDesc : *out_result) {
      _result.PushBack(propertyDesc->toValue(m_json_doc.GetAllocator()), m_json_doc.GetAllocator());
    }
    result.AddMember("result", _result, m_json_doc.GetAllocator());

    if (out_internalProperties.isJust()) {
      rapidjson::Value _privateProperties(rapidjson::kArrayType);
      for (const auto &internalProp : *out_internalProperties.fromJust()) {
        _privateProperties.PushBack(internalProp->toValue(m_json_doc.GetAllocator()), m_json_doc.GetAllocator());
      }
      result.AddMember("internalProperties", _privateProperties, m_json_doc.GetAllocator());
    }

    if (out_privateProperties.isJust()) {
      rapidjson::Value _out_privateProperties(rapidjson::kArrayType);
      for (const auto &privateProp : *out_privateProperties.fromJust()) {
        _out_privateProperties.PushBack(privateProp->toValue(m_json_doc.GetAllocator()), m_json_doc.GetAllocator());
      }
      result.AddMember("privateProperties", _out_privateProperties, m_json_doc.GetAllocator());
    }

    if (out_exceptionDetails.isJust()) {
      result.AddMember("exceptionDetails", out_exceptionDetails.fromJust()->toValue(m_json_doc.GetAllocator()),
                       m_json_doc.GetAllocator());
    }
  }
  if (weak->get()) weak->get()->sendResponse(callId, response, std::move(result));
  return;
}

void RuntimeDispatcherImpl::globalLexicalScopeNames(uint64_t callId, const std::string &method,
                                                    JSONObject message, ErrorSupport *) {}

void RuntimeDispatcherImpl::queryObjects(uint64_t callId, const std::string &method, JSONObject message,
                                         ErrorSupport *) {}

void RuntimeDispatcherImpl::releaseObject(uint64_t callId, const std::string &method, JSONObject message,
                                          ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  std::string in_objectId = "";
  if (message.HasMember("objectId") && message["objectId"].IsString()) {
    in_objectId = message["objectId"].GetString();
  } else {
    errors->setName("objectId");
    errors->addError("objectId not found");
  }
  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->releaseObject(in_objectId);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void RuntimeDispatcherImpl::releaseObjectGroup(uint64_t callId, const std::string &method, JSONObject message,
                                               ErrorSupport *errors) {
  // Prepare input parameters.
  errors->push();
  std::string in_objectGroup = "";
  if (message.HasMember("objectGroup") && message["objectGroup"].IsString()) {
    in_objectGroup = message["objectGroup"].GetString();
  } else {
    errors->setName("objectGroup");
    errors->addError("objectGroup not found");
  }

  errors->pop();
  if (errors->hasErrors()) {
    reportProtocolError(callId, kInvalidParams, kInvalidParamsString, errors);
    return;
  }

  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->releaseObjectGroup(in_objectGroup);
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void RuntimeDispatcherImpl::runIfWaitingForDebugger(uint64_t callId, const std::string &method,
                                                    JSONObject message, ErrorSupport *) {
  std::unique_ptr<DispatcherBase::WeakPtr> weak = weakPtr();
  DispatchResponse response = m_backend->runIfWaitingForDebugger();
  if (response.status() == DispatchResponse::kFallThrough) {
    channel()->fallThrough(callId, method, std::move(message));
    return;
  }
  if (weak->get()) weak->get()->sendResponse(callId, response);
  return;
}

void RuntimeDispatcherImpl::runScript(uint64_t callId, const std::string &method, JSONObject message,
                                      ErrorSupport *) {}

void RuntimeDispatcherImpl::setCustomObjectFormatterEnabled(uint64_t callId, const std::string &method,
                                                            JSONObject message, ErrorSupport *) {}

void RuntimeDispatcherImpl::setMaxCallStackSizeToCapture(uint64_t callId, const std::string &method,
                                                         JSONObject message, ErrorSupport *) {}

void RuntimeDispatcherImpl::terminateExecution(uint64_t callId, const std::string &method, JSONObject message,
                                               ErrorSupport *) {}

void RuntimeDispatcherImpl::addBinding(uint64_t callId, const std::string &method, JSONObject message,
                                       ErrorSupport *) {}

void RuntimeDispatcherImpl::removeBinding(uint64_t callId, const std::string &method, JSONObject message,
                                          ErrorSupport *) {}

} // namespace debugger
} // namespace kraken
