import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:prozapoti/view/intro_page.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //*********************************Initializations************************************* */
  int pageIndex = 0;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? webViewController;
  void onStart() {
    Timer(
        const Duration(seconds: 2),
        () => setState(() {
              pageIndex = 1;
            }));

    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  void initState() {
    super.initState();
    onStart();
  }

//***********************************Social application navigation control management************************************** */
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

  //*************************************Application exit Control logic************************************ */
  Future<bool> showExitPopup(context) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Do you want to exit?"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            exit(0);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
                          child: const Text("Yes"),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        child: const Text("No", style: TextStyle(color: Colors.black)),
                      ))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

//*********************************************Build method******************************************* */
  @override
  Widget build(BuildContext context) {
    Future<bool> onWillPopPress() async {
      if (await webViewController?.canGoBack() ?? false) {
        webViewController?.goBack();
        return false;
      }
      return showExitPopup(context);
    }

    return WillPopScope(
        onWillPop: () => onWillPopPress(),
        child: Scaffold(
          body: SafeArea(
            child: pageIndex == 0
                ? const IntroPage()
                : InAppWebView(
                    initialUrlRequest: URLRequest(url: Uri.parse(url)),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true),
                    ),
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (InAppWebViewController controller) {
                      webViewController = controller;
                    },
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
                    onLoadStop: (controller, url) {
                      pullToRefreshController?.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController?.endRefreshing();
                      }
                    }),
          ),
        ));
  }
}
