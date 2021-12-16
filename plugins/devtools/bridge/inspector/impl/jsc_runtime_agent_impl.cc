/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "jsc_runtime_agent_impl.h"
#include "inspector/inspector_session.h"
#include <JavaScriptCore/DeleteAllCodeEffort.h>

namespace kraken {
namespace debugger {

JSCRuntimeAgentImpl::JSCRuntimeAgentImpl(kraken::debugger::InspectorSession *session,
                                         kraken::debugger::AgentContext &context)
  : m_session(session), m_frontend(context.channel), m_debugger(context.debugger),
    m_injectedScriptManager(context.injectedScriptManager) {}

static Inspector::ScriptDebugServer::PauseOnExceptionsState
setPauseOnExceptionsState(Inspector::ScriptDebugServer &scriptDebugServer,
                          Inspector::ScriptDebugServer::PauseOnExceptionsState newState) {
  Inspector::ScriptDebugServer::PauseOnExceptionsState presentState = scriptDebugServer.pauseOnExceptionsState();
  if (presentState != newState) scriptDebugServer.setPauseOnExceptionsState(newState);
  return presentState;
}

/***************** RuntimeBackend *********************/
void JSCRuntimeAgentImpl::awaitPromise(const std::string &in_promiseObjectId, Maybe<bool> in_returnByValue,
                                       Maybe<bool> in_generatePreview, std::unique_ptr<AwaitPromiseCallback> callback) {
  // TODO
}

bool JSCRuntimeAgentImpl::convertRemoteObject(const std::string &in_result, std::unique_ptr<RemoteObject> *out_result,
                                              Inspector::ErrorString &error) {
  rapidjson::Document in_result_doc;
  in_result_doc.Parse(in_result.c_str());
  if (in_result_doc.HasParseError() || !in_result_doc.IsObject()) {
    KRAKEN_LOG(ERROR) << "remoteObject parsed error...";
    return false;
  }
  auto copy = rapidjson::Value(in_result_doc, m_doc.GetAllocator());
  ErrorSupport errorSupport;
  *out_result = debugger::RemoteObject::fromValue(&copy, &errorSupport);
  if (errorSupport.hasErrors()) {
    error = errorSupport.errors().c_str();
    return false;
  }
  return true;
}

void JSCRuntimeAgentImpl::callFunctionOn(const std::string &in_functionDeclaration, Maybe<std::string> in_objectId,
                                         Maybe<std::vector<std::unique_ptr<CallArgument>>> in_arguments,
                                         Maybe<bool> in_silent, Maybe<bool> in_returnByValue,
                                         Maybe<bool> in_generatePreview, Maybe<bool> in_userGesture,
                                         Maybe<bool> in_awaitPromise, Maybe<int> in_executionContextId,
                                         Maybe<std::string> in_objectGroup,
                                         std::unique_ptr<CallFunctionOnCallback> callback) {
  if (!in_objectId.isJust()) {
    callback->sendFailure(DispatchResponse::Error("params invalid. objectId not specified"));
    return;
  }

  Inspector::InjectedScript injectedScript =
    m_injectedScriptManager->injectedScriptForObjectId(in_objectId.fromJust().c_str());
  if (injectedScript.hasNoValue()) {
    callback->sendFailure(DispatchResponse::Error("Could not find InjectedScript for objectId"));
    return;
  }

  std::string arguments;
  if (in_arguments.isJust()) {
    rapidjson::Document doc;
    doc.SetArray();
    for (auto &&arg : *in_arguments.fromJust()) {
      doc.PushBack(arg->toValue(doc.GetAllocator()), doc.GetAllocator());
    }

    rapidjson::StringBuffer buffer;
    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
    doc.Accept(writer);
    arguments = buffer.GetString();
  }
  RefPtr<Inspector::Protocol::Runtime::RemoteObject> out_result;
  WTF::String errorString;
  WTF::Optional<bool> wasThrown;
  injectedScript.callFunctionOn(errorString, in_objectId.fromJust().c_str(), in_functionDeclaration.c_str(),
                                arguments.c_str(), in_returnByValue.fromMaybe(false),
                                in_generatePreview.fromMaybe(false), out_result, wasThrown);

  if (!errorString.isEmpty() || !out_result) {
    callback->sendFailure(DispatchResponse::Error(errorString.utf8().data()));
    return;
  }

  std::unique_ptr<RemoteObject> result;
  convertRemoteObject(out_result->toJSONString().utf8().data(), &result, errorString);
  if (!errorString.isEmpty() || !result) {
    callback->sendFailure(DispatchResponse::Error(errorString.utf8().data()));
    return;
  }

  callback->sendSuccess(std::move(result), {});
}

DispatchResponse JSCRuntimeAgentImpl::compileScript(const std::string &in_expression, const std::string &in_sourceURL,
                                                    bool in_persistScript, Maybe<int> in_executionContextId,
                                                    Maybe<std::string> *out_scriptId,
                                                    Maybe<ExceptionDetails> *out_exceptionDetails) {
  int executionContextId = in_executionContextId.fromMaybe(0);
  WTF::String errorString;
  Inspector::InjectedScript injectedScript = injectedScriptForEval(errorString, &executionContextId);
  if (!errorString.isEmpty()) {
    return DispatchResponse::Error(errorString.utf8().data());
  }
  if (injectedScript.hasNoValue()) {
    return DispatchResponse::Error("injected script not found");
  }

  return DispatchResponse::OK();
}

DispatchResponse JSCRuntimeAgentImpl::disable() {
  m_enabled = false;
  m_frontend.executionContextDestroyed(0);
  return DispatchResponse::OK();
}

DispatchResponse JSCRuntimeAgentImpl::discardConsoleEntries() {
  return DispatchResponse::Error("not implement yet");
}

DispatchResponse JSCRuntimeAgentImpl::enable() {
  m_enabled = true;
  m_frontend.executionContextCreated(
    ExecutionContextDescription::create().setId(m_session->rpcSession()->sessionId()).setName("default").setOrigin("default").setAuxData(nullptr).build());
  return DispatchResponse::OK();
}

Inspector::InjectedScript JSCRuntimeAgentImpl::injectedScriptForEval(WTF::String &errorString,
                                                                     const int *executionContextId) {
  JSC::ExecState *scriptState = m_debugger->globalObject()->globalExec();
  Inspector::InjectedScript injectedScript = m_injectedScriptManager->injectedScriptFor(scriptState);
  if (injectedScript.hasNoValue())
    errorString = ASCIILiteral::fromLiteralUnsafe("Internal error: main world execution context not found.");
  return injectedScript;
}

void JSCRuntimeAgentImpl::evaluate(const std::string &in_expression, Maybe<std::string> in_objectGroup,
                                   Maybe<bool> in_includeCommandLineAPI, Maybe<bool> in_silent, Maybe<int> in_contextId,
                                   Maybe<bool> in_returnByValue, Maybe<bool> in_generatePreview,
                                   Maybe<bool> in_userGesture, Maybe<bool> in_awaitPromise,
                                   Maybe<bool> in_throwOnSideEffect, Maybe<double> in_timeout,
                                   std::unique_ptr<EvaluateCallback> callback) {
  int executionContextId = in_contextId.fromMaybe(0);
  WTF::String errorString;
  Inspector::InjectedScript injectedScript = injectedScriptForEval(errorString, &executionContextId);
  if (!errorString.isEmpty()) {
    callback->sendFailure(DispatchResponse::Error(errorString.utf8().data()));
    return;
  }
  if (injectedScript.hasNoValue()) {
    callback->sendFailure(DispatchResponse::Error("injected script not found"));
    return;
  }

  WTF::Optional<bool> wasThrown;
  WTF::Optional<int> savedResultIndex;
  RefPtr<Inspector::Protocol::Runtime::RemoteObject> result;
  injectedScript.evaluate(errorString, in_expression.c_str(), in_objectGroup.fromMaybe("").c_str(),
                          in_includeCommandLineAPI.fromMaybe(false), in_returnByValue.fromMaybe(false),
                          in_generatePreview.fromMaybe(false),
                          false, // saveResult
                          result, wasThrown, savedResultIndex);

  if (result) {
    std::unique_ptr<RemoteObject> resultV8;
    convertRemoteObject(result->toJSONString().utf8().data(), &resultV8, errorString);
    if (resultV8) {
      callback->sendSuccess(std::move(resultV8), {});
    } else {
      callback->sendFailure(DispatchResponse::Error(errorString.utf8().data()));
    }
  } else {
    callback->sendFailure(DispatchResponse::Error("Runtime.evaluate internal error"));
  }
}

DispatchResponse JSCRuntimeAgentImpl::getIsolateId(std::string *out_id) {
  return DispatchResponse::Error("not implement yet");
}

DispatchResponse JSCRuntimeAgentImpl::getHeapUsage(double *out_usedSize, double *out_totalSize) {
  if (!m_debugger || !m_debugger->globalObject()) {
    return DispatchResponse::Error("internal error");
  }
  auto &vm = m_debugger->vm();
  JSC::JSLockHolder holder(vm);
  auto &heap = vm.heap;
  *out_usedSize = heap.size();
  *out_totalSize = heap.capacity();

  //            *out_usedSize = 0;
  //            *out_totalSize = 0;
  return DispatchResponse::OK();
}

static WTF::String generatePreview(const rapidjson::Value &value) {
  WTF::StringBuilder builder;
  if (value.HasMember("value")) {
    if (value["value"].IsString()) {
      builder.append("\"");
      builder.append(value["value"].GetString());
      builder.append("\"");
    } else if (value["value"].IsBool()) {
      builder.append(value["value"].GetBool() ? "true" : "false");
    } else if (value["value"].IsDouble()) {
      builder.append(value["value"].GetDouble());
    } else if (value["value"].IsInt()) {
      builder.append(value["value"].GetInt());
    } else {
      builder.append("\"unknown\"");
    }

  } else if (value.HasMember("description") && value["description"].IsString()) {
    builder.append("\"");
    builder.append(value["description"].GetString());
    builder.append("\"");
  } else if (value.HasMember("className") && value["className"].IsString()) {
    builder.append("\"");
    builder.append(value["className"].GetString());
    builder.append("\"");
  } else if (value.HasMember("type") && value["type"].IsString()) {
    builder.append("\"");
    builder.append(value["type"].GetString());
    builder.append("\"");
  } else {
    builder.append("\"");
    builder.append("unknown");
    builder.append("\"");
  }
  return builder.toString();
}

DispatchResponse JSCRuntimeAgentImpl::getProperties(
  const std::string &in_objectId, Maybe<bool> in_ownProperties, Maybe<bool> in_accessorPropertiesOnly,
  Maybe<bool> in_generatePreview, std::unique_ptr<std::vector<std::unique_ptr<PropertyDescriptor>>> *out_result,
  Maybe<std::vector<std::unique_ptr<InternalPropertyDescriptor>>> *out_internalProperties,
  Maybe<std::vector<std::unique_ptr<PrivatePropertyDescriptor>>> *out_privateProperties,
  Maybe<ExceptionDetails> *out_exceptionDetails) {
  WTF::String objectId = in_objectId.c_str();

  Inspector::ErrorString errorString;
  Inspector::InjectedScript injectedScript = m_injectedScriptManager->injectedScriptForObjectId(objectId);
  if (injectedScript.hasNoValue()) {
    errorString = ASCIILiteral::fromLiteralUnsafe("Could not find InjectedScript for objectId");
    return DispatchResponse::Error(errorString.utf8().data());
  }

  // resolve objectId
  rapidjson::Document d;
  d.Parse(in_objectId.c_str());
  if (d.HasMember("type") && d["type"].IsString() && strcmp(d["type"].GetString(), "collection") == 0) {
    // map or set
    RefPtr<JSON::ArrayOf<Inspector::Protocol::Runtime::CollectionEntry>> collection_entries;
    injectedScript.getCollectionEntries(errorString, objectId, WTF::String(), 0, 0, collection_entries);
    if (!collection_entries) {
      return DispatchResponse::Error("target object is not a collection");
    }
    rapidjson::Document collectionJson;
    collectionJson.Parse(collection_entries->toJSONString().utf8().data());
    if (!collectionJson.IsArray()) {
      return DispatchResponse::Error("target object is not a collection");
    }
    *out_result = std::make_unique<std::vector<std::unique_ptr<PropertyDescriptor>>>();
    int index = 0;
    for (auto &entry : collectionJson.GetArray()) {
      // 不支持嵌套
      WTF::StringBuilder desc;
      if (entry.HasMember("key") && entry.HasMember("value")) {
        desc.append("{");
        desc.append(generatePreview(entry["key"]).characters8());
        desc.append(" => ");
        desc.append(generatePreview(entry["value"]).characters8());
        desc.append("}");
      } else if (entry.HasMember("value")) {
        desc.append(generatePreview(entry["value"]).characters8());
      }

      auto remoteObj = RemoteObject::create()
                         .setType("Object")
                         .setSubtype("Object")
                         .setObjectId("")
                         .setValue(nullptr)
                         .setUnserializableValue("")
                         .setDescription(desc.toString().utf8().data())
                         //                            .setPreview(std::move(preview))
                         .build();

      auto descriptor = PropertyDescriptor::create()
                          .setEnumerable(true)
                          .setConfigurable(true)
                          .setName(std::to_string(index++))
                          .setValue(std::move(remoteObj))
                          .build();

      (*out_result)->push_back(std::move(descriptor));
    }

    return DispatchResponse::OK();
  }

  Inspector::ScriptDebugServer::PauseOnExceptionsState previousPauseOnExceptionsState =
    setPauseOnExceptionsState(*m_debugger, Inspector::ScriptDebugServer::DontPauseOnExceptions);

  RefPtr<JSON::ArrayOf<Inspector::Protocol::Runtime::PropertyDescriptor>> result;
  RefPtr<JSON::ArrayOf<Inspector::Protocol::Runtime::InternalPropertyDescriptor>> internalProperties;

  injectedScript.getProperties(errorString, objectId, in_ownProperties.fromMaybe(false),
                               in_generatePreview.fromMaybe(false), result);

  injectedScript.getInternalProperties(errorString, objectId, in_generatePreview.fromMaybe(false), internalProperties);

  // TODO: support set / map ...
//  RefPtr<JSON::ArrayOf<Inspector::Protocol::Runtime::CollectionEntry>> collection_entries;
//  injectedScript.getCollectionEntries(errorString, objectId, WTF::String(), 0, 0, collection_entries);
//
//  if (collection_entries && result) {
//    auto descriptor = Inspector::Protocol::Runtime::PropertyDescriptor::create()
//                        .setName("[[Entries]]")
//                        .setEnumerable(true)
//                        .setConfigurable(false)
//                        .release();
//    auto remoteObj = Inspector::Protocol::Runtime::RemoteObject::create()
//                       .setType(Inspector::Protocol::Runtime::RemoteObject::Type::Object)
//                       .release();
//    WTF::StringBuilder builder;
//    builder.append("Array(");
//    builder.append(WTF::String::number(collection_entries->length()));
//    builder.append(")");
//    remoteObj->setDescription(builder.toString());
//
//    d.AddMember("type", "collection", d.GetAllocator());
//    rapidjson::StringBuffer buffer;
//    rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
//    d.Accept(writer);
//    remoteObj->setObjectId(buffer.GetString());
//    descriptor->setValue(std::move(remoteObj));
//    result->addItem(std::move(descriptor));
//  }

  setPauseOnExceptionsState(*m_debugger, previousPauseOnExceptionsState);

  // transfer jsc -> v8

  if (result == nullptr) {
    return DispatchResponse::Error("result not found");
  }

  *out_result = std::make_unique<std::vector<std::unique_ptr<PropertyDescriptor>>>();

  std::string resultStr = result->toJSONString().utf8().data();

  rapidjson::Document result_obj;
  result_obj.Parse(resultStr.c_str());
  if (result_obj.HasParseError() || !result_obj.IsArray()) {
    KRAKEN_LOG(ERROR) << "[Runtime.getProperties] resultObj parsed error...";
    KRAKEN_LOG(ERROR) << result_obj.HasParseError() << "|" << result_obj.IsArray() << "|" << resultStr.c_str();
    return DispatchResponse::Error("resultObj parsed json error");
  }

  for (auto &propItem : result_obj.GetArray()) {
    if (propItem.IsObject()) {
      ErrorSupport err;
      auto prop = PropertyDescriptor::fromValue(&propItem, &err);
      if (err.hasErrors()) {
        KRAKEN_LOG(ERROR) << "[Runtime.getProperties] PropertyDescriptor transformed error," << err.errors();
        continue;
      }
      (*out_result)->push_back(std::move(prop));
    }
  }

  if (internalProperties != nullptr) {
    *out_internalProperties = std::make_unique<std::vector<std::unique_ptr<InternalPropertyDescriptor>>>();
    std::string internalPropStr = internalProperties->toJSONString().utf8().data();

    rapidjson::Document internal_prop_obj;
    internal_prop_obj.Parse(internalPropStr.c_str());
    if (internal_prop_obj.HasParseError() || !internal_prop_obj.IsArray()) {
      KRAKEN_LOG(ERROR) << "[Runtime.getProperties] internal_prop_obj parsed error...";
      return DispatchResponse::Error("resultObj parsed json error");
    }

    for (auto &internalPropItem : internal_prop_obj.GetArray()) {
      if (internalPropItem.IsObject()) {
        ErrorSupport err;
        auto internalProp = InternalPropertyDescriptor::fromValue(&internalPropItem, &err);
        if (err.hasErrors()) {
          KRAKEN_LOG(ERROR) << "[Runtime.getProperties] PropertyDescriptor transformed error," << err.errors();
          continue;
        }
        (*out_internalProperties).fromJust()->push_back(std::move(internalProp));
      }
    }
  }

  return DispatchResponse::OK();
}

DispatchResponse JSCRuntimeAgentImpl::globalLexicalScopeNames(Maybe<int> in_executionContextId,
                                                              std::unique_ptr<std::vector<std::string>> *out_names) {
  return DispatchResponse::Error("not implement yet");
}

DispatchResponse JSCRuntimeAgentImpl::queryObjects(const std::string &in_prototypeObjectId,
                                                   Maybe<std::string> in_objectGroup,
                                                   std::unique_ptr<RemoteObject> *out_objects) {
  return DispatchResponse::Error("not implement yet");
}

DispatchResponse JSCRuntimeAgentImpl::releaseObject(const std::string &in_objectId) {
  WTF::String objectId = in_objectId.c_str();
  Inspector::InjectedScript injectedScript = m_injectedScriptManager->injectedScriptForObjectId(objectId);
  if (!injectedScript.hasNoValue()) injectedScript.releaseObject(objectId);
  return DispatchResponse::OK();
}

DispatchResponse JSCRuntimeAgentImpl::releaseObjectGroup(const std::string &in_objectGroup) {
  m_injectedScriptManager->releaseObjectGroup(in_objectGroup.c_str());
  return DispatchResponse::OK();
}

DispatchResponse JSCRuntimeAgentImpl::runIfWaitingForDebugger() {
  return DispatchResponse::OK();
}

void JSCRuntimeAgentImpl::runScript(const std::string &in_scriptId, Maybe<int> in_executionContextId,
                                    Maybe<std::string> in_objectGroup, Maybe<bool> in_silent,
                                    Maybe<bool> in_includeCommandLineAPI, Maybe<bool> in_returnByValue,
                                    Maybe<bool> in_generatePreview, Maybe<bool> in_awaitPromise,
                                    std::unique_ptr<RunScriptCallback> callback) {
  // TODO
}

DispatchResponse JSCRuntimeAgentImpl::setCustomObjectFormatterEnabled(bool in_enabled) {
  return DispatchResponse::Error("not implement yet");
}

DispatchResponse JSCRuntimeAgentImpl::setMaxCallStackSizeToCapture(int in_size) {
  return DispatchResponse::Error("not implement yet");
}

void JSCRuntimeAgentImpl::terminateExecution(std::unique_ptr<TerminateExecutionCallback> callback) {
  // TODO
}

DispatchResponse JSCRuntimeAgentImpl::addBinding(const std::string &in_name, Maybe<int> in_executionContextId) {
  return DispatchResponse::Error("not implement yet");
}

DispatchResponse JSCRuntimeAgentImpl::removeBinding(const std::string &in_name) {
  return DispatchResponse::Error("not implement yet");
}

JSCRuntimeAgentImpl::~JSCRuntimeAgentImpl() {
  m_frontend.executionContextsCleared(
      ExecutionContextDescription::create().setId(m_session->rpcSession()->sessionId()).setName("default").setOrigin("default").setAuxData(nullptr).build());
}

/// Own

void JSCRuntimeAgentImpl::setTypeProfilerEnabledState(bool isTypeProfilingEnabled) {
  if (m_isTypeProfilingEnabled == isTypeProfilingEnabled) {
    return;
  }
  m_isTypeProfilingEnabled = isTypeProfilingEnabled;

  JSC::VM &vm = m_debugger->vm();
  vm.whenIdle([&vm, isTypeProfilingEnabled]() {
    bool shouldRecompileFromTypeProfiler =
      (isTypeProfilingEnabled ? vm.enableTypeProfiler() : vm.disableTypeProfiler());
    if (shouldRecompileFromTypeProfiler) vm.deleteAllCode(JSC::PreventCollectionAndDeleteAllCode);
  });
}

void JSCRuntimeAgentImpl::setControlFlowProfilerEnabledState(bool isControlFlowProfilingEnabled) {
  if (m_isControlFlowProfilingEnabled == isControlFlowProfilingEnabled) {
    return;
  }
  m_isControlFlowProfilingEnabled = isControlFlowProfilingEnabled;
  JSC::VM &vm = m_debugger->vm();
  vm.whenIdle([&vm, isControlFlowProfilingEnabled]() {
    bool shouldRecompileFromControlFlowProfiler =
      (isControlFlowProfilingEnabled ? vm.enableControlFlowProfiler() : vm.disableControlFlowProfiler());

    if (shouldRecompileFromControlFlowProfiler) vm.deleteAllCode(JSC::PreventCollectionAndDeleteAllCode);
  });
}

} // namespace debugger
} // namespace kraken
