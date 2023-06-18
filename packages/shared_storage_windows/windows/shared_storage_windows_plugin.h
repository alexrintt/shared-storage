#ifndef FLUTTER_PLUGIN_NSD_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_NSD_WINDOWS_PLUGIN_H_

#include "shared_storage_windows.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace shared_storage_windows {

	class NsdWindowsPlugin : public flutter::Plugin {
	public:
		static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

		NsdWindowsPlugin(std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> methodChannel);
		virtual ~NsdWindowsPlugin();

		// Disallow copy and assign.
		NsdWindowsPlugin(const NsdWindowsPlugin&) = delete;
		NsdWindowsPlugin& operator=(const NsdWindowsPlugin&) = delete;

	private:

		shared_storage_windows::NsdWindows shared_storageWindows;
	};

}  // namespace shared_storage_windows

#endif  // FLUTTER_PLUGIN_NSD_WINDOWS_PLUGIN_H_
