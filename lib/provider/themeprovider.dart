import 'package:flutter/material.dart';
import 'package:fanbae/utils/color.dart';

import '../utils/constant.dart';
import '../utils/sharedpre.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  Future<void> loadTheme() async {
    SharedPre sharedPre = SharedPre();
    final isDark = await sharedPre.read('isDarkMode') ?? 'true';
    toggleTheme(isDark == "true" ? true : false, notify: false);
  }

  Future<void> toggleTheme(bool isOn, {bool notify = true}) async {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    appbgcolor = isOn ? const Color(0xff060713) : const Color(0xffffffff);
    white = isOn ? const Color(0xffffffff) : const Color(0xff000000);
    black = isOn ? const Color(0xff000000) : const Color(0xffffffff);
    appBarColor = isOn ? const Color(0xff05060F) : const Color(0xfffcfcfc);
    colorAccent = isOn ? const Color(0xffffffff) : const Color(0xff000000);
    colorPrimaryDark = isOn ? const Color(0xff1D1E27) : const Color(0xffF5F6FA);
    buttonDisable = isOn ? const Color(0x4f5c5c5c) : const Color(0x4fB0B0B0);
    textColor = isOn ? const Color(0xFF0EB1FC) : const Color(0xFF01DED1);
    Constant.darkMode = isOn ? "true" : 'false';

    // Save theme mode to preferences
    SharedPre sharedPre = SharedPre();
    await sharedPre.save('isDarkMode', Constant.darkMode);
    if (notify) notifyListeners();
  }
}
