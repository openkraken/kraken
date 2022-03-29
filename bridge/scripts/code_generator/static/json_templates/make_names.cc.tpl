// Generated from template:
//   code_generator/src/json/templates/make_names.h.tmpl
// and input files:
//   <%= template_path %>


#ifndef <%= _.snakeCase(name).toUpperCase() %>_H_
#define <%= _.snakeCase(name).toUpperCase() %>_H_

#include "third_party/blink/renderer/platform/wtf/text/atomic_string.h"
#include "third_party/blink/renderer/core/core_export.h"

namespace kraken {

extern const WTF::AtomicString& kAbort;

constexpr unsigned kNamesCount = 352;

void Init();

} // kraken

#endif  // #define <%= _.snakeCase(name).toUpperCase() %>
