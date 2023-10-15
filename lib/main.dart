import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, home: WebViewExample()));

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            alignment: Alignment.center,
            child: const Text(
              '',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            child: MyWebViewWidget(),
          ),
        ],
      ),
    );
  }
}

class MyWebViewWidget extends StatefulWidget {
  const MyWebViewWidget({super.key});

  @override
  State<MyWebViewWidget> createState() => _MyWebViewWidgetState();
}

class _MyWebViewWidgetState extends State<MyWebViewWidget> {
  final String url = 'https://www.humairasbd.com';
  late final WebViewController controller;

  /// External link idenfiers
  bool isSocialMediaLink(String rawLink) =>
      rawLink.startsWith('whatsapp') ||
      rawLink.contains('fb') ||
      rawLink.contains('youtube') ||
      rawLink.contains('twitter') ||
      rawLink.contains('instagram') ||
      rawLink.contains('tiktok');
  bool isCantctNumber(String rawLink) => rawLink.startsWith('tel:+88');
  bool isEmail(String rawLink) => rawLink.contains('@gmail.com');

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (isSocialMediaLink(request.url) ||
                isCantctNumber(request.url) ||
                isEmail(request.url)) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  _launchURL(String url) async {
    late Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
