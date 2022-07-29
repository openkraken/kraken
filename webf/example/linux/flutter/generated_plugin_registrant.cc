//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <webf/webf_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) webf_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WebfPlugin");
  webf_plugin_register_with_registrar(webf_registrar);
}
