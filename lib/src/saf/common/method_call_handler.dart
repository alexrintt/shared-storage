import 'dart:developer';

import 'package:flutter/services.dart';

import '../../channels.dart';

typedef MethodCallHandler<T> = void Function(
  T arguments,
  UnsubscribeFn unsubscribe,
);

final Map<String, MethodCallHandler> _listeners = <String, MethodCallHandler>{};

Future<dynamic> _methodCallHandler(MethodCall call) async {
  final MethodCallHandler? handler = _listeners[call.method];

  handler?.call(call.arguments, () => removeMethodCallListener(call.method));

  if (handler == null) {
    log('Tried to invoke undefined handler: ${call.method} with args ${call.arguments}');
  }

  return null;
}

void _setupMethodCallHandler() {
  kDocumentFileChannel.setMethodCallHandler(_methodCallHandler);
}

void _removeMethodCallHandler() {
  kDocumentFileChannel.setMethodCallHandler(null);
}

void _removeMethodCallHandlerIfThereAreNoMoreListeners() {
  if (_listeners.isEmpty) {
    _removeMethodCallHandler();
  }
}

typedef UnsubscribeFn = void Function();

UnsubscribeFn addMethodCallListener<T>(String method, MethodCallHandler<T> fn) {
  void unsubscribe() => removeMethodCallListener(method);

  _listeners[method] = (dynamic arguments, UnsubscribeFn unsubscribe) {
    if (arguments is T) {
      fn(arguments, unsubscribe);
    }
  };

  _setupMethodCallHandler();

  return unsubscribe;
}

void removeMethodCallListener(String method) {
  _listeners.remove(method);
  _removeMethodCallHandlerIfThereAreNoMoreListeners();
}

void addMapMethodCallListener<K, V>(
  String method,
  MethodCallHandler<Map<K, V>> fn,
) {
  addMethodCallListener(method, (dynamic arguments, UnsubscribeFn unsubscribe) {
    if (arguments is Map<dynamic, dynamic>) {
      try {
        fn(Map<K, V>.from(arguments), unsubscribe);
      } finally {}
    }
  });

  _setupMethodCallHandler();
}
