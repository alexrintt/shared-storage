#include "include/shared_storage_windows/shared_storage_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "shared_storage_windows_plugin.h"

void NsdWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  shared_storage_windows::NsdWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
