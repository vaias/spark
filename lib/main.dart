import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spark/view/web_view_page.dart';
import 'view/intro_page.dart';

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
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 2),
        () => setState(() {
              pageIndex = 1;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: pageIndex == 0 ? const IntroPage() : const WebViewPage(),
      ),
    );
  }
}
