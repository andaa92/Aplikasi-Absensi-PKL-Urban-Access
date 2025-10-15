//
//  Generated file. Do not edit.
//

// clang-format off

// Forward-declare PluginRegistry to avoid requiring Flutter headers in IDE includePath checks.
namespace flutter {
class PluginRegistry;
}

#if defined(__has_include)
# if __has_include(<file_selector_windows/file_selector_windows.h>)
#  include <file_selector_windows/file_selector_windows.h>
# endif
# if __has_include(<local_auth_windows/local_auth_plugin.h>)
#  include <local_auth_windows/local_auth_plugin.h>
# endif
# if __has_include(<permission_handler_windows/permission_handler_windows_plugin.h>)
#  include <permission_handler_windows/permission_handler_windows_plugin.h>
# endif
#endif


void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  LocalAuthPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("LocalAuthPlugin"));
  LocalAuthPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("LocalAuthPlugin"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));

}
