import 'dart:developer';
import 'package:fanbae/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fanbae/utils/color.dart';

class CommonPage extends StatefulWidget {
  final String url, title;
  final bool multilanguage;
  const CommonPage({
    super.key,
    required this.url,
    required this.title,
    required this.multilanguage,
  });

  @override
  State<CommonPage> createState() => CommonPageState();
}

class CommonPageState extends State<CommonPage> {
  final GlobalKey webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    log("URL===> ${widget.url}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbgcolor,
      appBar:
          Utils().otherPageAppBar(context, widget.title, widget.multilanguage),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              onLoadStart: (controller, url) {},
              onLoadStop: (controller, url) {},
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            ),
          ),
        ],
      ),
    );
  }
}
