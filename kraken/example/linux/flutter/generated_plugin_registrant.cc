//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <kraken/kraken_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) kraken_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "KrakenPlugin");
  kraken_plugin_register_with_registrar(kraken_registrar);
}
