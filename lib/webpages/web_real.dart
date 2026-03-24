// lib/web_real.dart
// Web implementation: uses dart:html and dart:js_util.
import 'dart:html' as html;
import 'dart:js_util' as js_util;

String? getDeepLinkWeb() {
  try {
    final deep = js_util.getProperty(html.window, 'Fanbae_DEEPLINK');
    if (deep != null && deep.toString().isNotEmpty) {
      return deep.toString();
    }
    // If no injected var, use location.href as fallback.
    return html.window.location.href;
  } catch (e) {
    // Any error -> null
    return null;
  }
}
