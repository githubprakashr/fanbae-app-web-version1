// Stub for dart:js on non-web platforms
// This file provides empty stubs for dart:js functionality
// when building for mobile platforms

// Empty stub - dart:js is not available on mobile
class JsObject {
  dynamic callMethod(String method, [List<dynamic>? args]) {
    throw UnsupportedError('dart:js is not supported on this platform');
  }
}

class JsContext {
  JsObject get context => JsObject();
}

// Stub for allowInterop
dynamic allowInterop(Function f) {
  throw UnsupportedError('dart:js is not supported on this platform');
}

// Export context as a getter
final context = JsObject();
