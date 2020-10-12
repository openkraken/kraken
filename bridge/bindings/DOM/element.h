//
// Created by andycall on 2020/9/23.
//

#ifndef KRAKENBRIDGE_ELEMENT_H
#define KRAKENBRIDGE_ELEMENT_H

#include "jsa.h"
#include "include/kraken_bridge.h"

namespace kraken {
namespace binding {
using namespace alibaba::jsa;

class JSElementStyle : public HostObject {
  Value get(JSContext &, const PropNameID &name) override;
  void set(JSContext &, const PropNameID &name, const Value &value) override;
  std::vector<PropNameID> getPropertyNames(JSContext &context) override;
};

class JSElement : public HostObject {
public:
  JSElement() = delete;
  explicit JSElement(JSContext &context, NativeString *tagName);
  ~JSElement() override {
    // TODO: call dart method to recycle dart side element.
    // dartMethod.removeElement();
  }

  Value get(JSContext &, const PropNameID &name) override;

  void set(JSContext &, const PropNameID &name, const Value &value) override;

  std::vector<PropNameID> getPropertyNames(JSContext &context) override;

private:
  NativeElement * _dartElement;
};

} // namespace binding
} // namespace kraken
#endif // KRAKENBRIDGE_ELEMENT_H
