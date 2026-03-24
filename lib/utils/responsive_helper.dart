import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobilePhone() {
    if (!kIsWeb) {
      return true;
    } else {
      return false;
    }
  }

  static bool isWeb(BuildContext context) {
    return kIsWeb;
  }

  static bool checkIsWeb(BuildContext context) {
    return kIsWeb && !ResponsiveHelper.isMobile(context) && !ResponsiveHelper.isTab(context);
  }

  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    if (size < 600 || !kIsWeb) {
      return true;
    } else {
      return false;
    }
  }

  static bool isTab(context) {
    final size = MediaQuery.of(context).size.width;
    if (size < 1024 && size  >= 600) {
      return true;
    } else {
      return false;
    }
  }

  static bool isDesktop(context) {
    final size = MediaQuery.of(context).size.width;
    if (size >= 1024) {
      return true;
    } else {
      return false;
    }
  }
}

class ResponsiveSwitcher extends StatefulWidget {
  final Widget mobilePage;
  final Widget desktopPage;

  const ResponsiveSwitcher({
    super.key,
    required this.mobilePage,
    required this.desktopPage,
  });

  @override
  State<ResponsiveSwitcher> createState() => _ResponsiveSwitcherState();
}

class _ResponsiveSwitcherState extends State<ResponsiveSwitcher>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1024) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.desktopPage,
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.mobilePage,
        ),
      );
    }
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // nothing needed
  }
}



