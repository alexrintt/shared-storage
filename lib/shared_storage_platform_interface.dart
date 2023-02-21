import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class SharedStorage {
  static Stream<void> startWatchingUri(Uri uri) =>
      SharedStoragePlatformInterface.instance.startWatchingUri(uri);
}

abstract class SharedStoragePlatformInterface extends PlatformInterface {
  /// Constructs a SharedStoragePlatformInterface.
  SharedStoragePlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static SharedStoragePlatformInterface _instance =
      SharedStoragePlatformInterfaceMethodChannel();

  /// The default instance of [SharedStoragePlatformInterface] to use.
  ///
  /// Defaults to [SharedStoragePlatformInterfaceMethodChannel].
  static SharedStoragePlatformInterface get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SharedStoragePlatformInterface] when
  /// they register themselves.
  static set instance(SharedStoragePlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<void> startWatchingUri(Uri uri);
}

class SharedStoragePlatformInterfaceMethodChannel
    extends SharedStoragePlatformInterface {
  @override
  Stream<void> startWatchingUri(Uri uri) {
    throw UnsupportedError(
      'Android does not support this API, please instead consider handling cases where the file does not exists instead of relying to this API to be aware when some change happens.',
    );
  }
}
