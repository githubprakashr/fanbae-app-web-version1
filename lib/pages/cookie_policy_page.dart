import 'package:flutter/material.dart';
import 'package:fanbae/pages/commonpage.dart';
import 'package:fanbae/utils/constant.dart';

class CookiePolicyPage extends StatelessWidget {
  const CookiePolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    String baseUrl = Constant().baseurl.replaceAll('/api/', '/');
    final String cookiePolicyUrl = '${baseUrl}pages/cookie-policy';

    return CommonPage(
      url: cookiePolicyUrl,
      title: 'Cookie Policy',
      multilanguage: false,
    );
  }
}
