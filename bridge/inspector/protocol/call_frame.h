/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_CALL_FRAME_H
#define KRAKEN_DEBUGGER_CALL_FRAME_H

#include "inspector/protocol/error_support.h"
#include "inspector/protocol/location.h"
#include "inspector/protocol/remote_object.h"
#include "inspector/protocol/scope.h"
#include "kraken_foundation.h"
#include <memory>
#include <string>
#include <vector>

namespace kraken {
namespace debugger {
class CallFrame {
  KRAKEN_DISALLOW_COPY(CallFrame);

public:
  static std::unique_ptr<CallFrame> fromValue(rapidjson::Value *value, ErrorSupport *errors);

  ~CallFrame() {}

  std::string getCallFrameId() {
    return m_callFrameId;
  }

  void setCallFrameId(const std::string &value) {
    m_callFrameId = value;
  }

  std::string getFunctionName() {
    return m_functionName;
  }

  void setFunctionName(const std::string &value) {
    m_functionName = value;
  }

  bool hasFunctionLocation() {
    return m_functionLocation.isJust();
  }

  Location *getFunctionLocation(Location *defaultValue) {
    return m_functionLocation.isJust() ? m_functionLocation.fromJust() : defaultValue;
  }

  void setFunctionLocation(std::unique_ptr<Location> value) {
    m_functionLocation = std::move(value);
  }

  Location *getLocation() {
    return m_location.get();
  }

  void setLocation(std::unique_ptr<Location> value) {
    m_location = std::move(value);
  }

  std::string getUrl() {
    return m_url;
  }

  void setUrl(const std::string &value) {
    m_url = value;
  }

  std::vector<std::unique_ptr<Scope>> *getScopeChain() {
    return m_scopeChain.get();
  }

  void setScopeChain(std::unique_ptr<std::vector<std::unique_ptr<Scope>>> value) {
    m_scopeChain = std::move(value);
  }

  RemoteObject *getThis() {
    return m_this.get();
  }

  void setThis(std::unique_ptr<RemoteObject> value) {
    m_this = std::move(value);
  }

  bool hasReturnValue() {
    return m_returnValue.isJust();
  }

  RemoteObject *getReturnValue(RemoteObject *defaultValue) {
    return m_returnValue.isJust() ? m_returnValue.fromJust() : defaultValue;
  }

  void setReturnValue(std::unique_ptr<RemoteObject> value) {
    m_returnValue = std::move(value);
  }

  rapidjson::Value toValue(rapidjson::Document::AllocatorType &allocator) const;

  template <int STATE> class CallFrameBuilder {
  public:
    enum {
      NoFieldsSet = 0,
      CallFrameIdSet = 1 << 1,
      FunctionNameSet = 1 << 2,
      LocationSet = 1 << 3,
      UrlSet = 1 << 4,
      ScopeChainSet = 1 << 5,
      ThisSet = 1 << 6,
      AllFieldsSet = (CallFrameIdSet | FunctionNameSet | LocationSet | UrlSet | ScopeChainSet | ThisSet | 0)
    };

    CallFrameBuilder<STATE | CallFrameIdSet> &setCallFrameId(const std::string &value) {
      static_assert(!(STATE & CallFrameIdSet), "property callFrameId should not be set yet");
      m_result->setCallFrameId(value);
      return castState<CallFrameIdSet>();
    }

    CallFrameBuilder<STATE | FunctionNameSet> &setFunctionName(const std::string &value) {
      static_assert(!(STATE & FunctionNameSet), "property functionName should not be set yet");
      m_result->setFunctionName(value);
      return castState<FunctionNameSet>();
    }

    CallFrameBuilder<STATE> &setFunctionLocation(std::unique_ptr<Location> value) {
      m_result->setFunctionLocation(std::move(value));
      return *this;
    }

    CallFrameBuilder<STATE | LocationSet> &setLocation(std::unique_ptr<Location> value) {
      static_assert(!(STATE & LocationSet), "property location should not be set yet");
      m_result->setLocation(std::move(value));
      return castState<LocationSet>();
    }

    CallFrameBuilder<STATE | UrlSet> &setUrl(const std::string &value) {
      static_assert(!(STATE & UrlSet), "property url should not be set yet");
      m_result->setUrl(value);
      return castState<UrlSet>();
    }

    CallFrameBuilder<STATE | ScopeChainSet> &setScopeChain(std::unique_ptr<std::vector<std::unique_ptr<Scope>>> value) {
      static_assert(!(STATE & ScopeChainSet), "property scopeChain should not be set yet");
      m_result->setScopeChain(std::move(value));
      return castState<ScopeChainSet>();
    }

    CallFrameBuilder<STATE | ThisSet> &setThis(std::unique_ptr<RemoteObject> value) {
      static_assert(!(STATE & ThisSet), "property this should not be set yet");
      m_result->setThis(std::move(value));
      return castState<ThisSet>();
    }

    CallFrameBuilder<STATE> &setReturnValue(std::unique_ptr<RemoteObject> value) {
      m_result->setReturnValue(std::move(value));
      return *this;
    }

    std::unique_ptr<CallFrame> build() {
      static_assert(STATE == AllFieldsSet, "state should be AllFieldsSet");
      return std::move(m_result);
    }

  private:
    friend class CallFrame;

    CallFrameBuilder() : m_result(new CallFrame()) {}

    template <int STEP> CallFrameBuilder<STATE | STEP> &castState() {
      return *reinterpret_cast<CallFrameBuilder<STATE | STEP> *>(this);
    }

    std::unique_ptr<CallFrame> m_result;
  };

  static CallFrameBuilder<0> create() {
    return CallFrameBuilder<0>();
  }

private:
  CallFrame() {}

  std::string m_callFrameId;
  std::string m_functionName;
  Maybe<Location> m_functionLocation;
  std::unique_ptr<Location> m_location;
  std::string m_url;
  std::unique_ptr<std::vector<std::unique_ptr<Scope>>> m_scopeChain;
  std::unique_ptr<RemoteObject> m_this;
  Maybe<RemoteObject> m_returnValue;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_CALL_FRAME_H
