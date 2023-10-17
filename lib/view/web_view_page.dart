import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatelessWidget {
  const WebViewPage({super.key});
  final String url = 'https://www.humairasbd.com';
  bool isSocialMediaLink(String rawLink) =>
      rawLink.startsWith('whatsapp') || rawLink.contains('fb') || rawLink.contains('youtube') || rawLink.contains('twitter') || rawLink.contains('instagram') || rawLink.contains('tiktok');
  bool isCantctNumber(String rawLink) => rawLink.startsWith('tel:+88');
  bool isEmail(String rawLink) => rawLink.contains('@gmail.com');
  _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(url)),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true),
      ),
      shouldOverrideUrlLoading: (controller, request) async {
        var url = request.request.url;

        if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(url?.scheme)) {
          if (url != null) {
            await _launchURL(
              url,
            );

            return NavigationActionPolicy.CANCEL;
          }
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}
