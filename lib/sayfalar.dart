import 'package:flutter/material.dart';
import 'islerim.dart';
import 'kamera.dart' as kamerapage;


class sayfalar extends StatefulWidget {
  @override
  _sayfalarState createState() => _sayfalarState();
}

class _sayfalarState extends State<sayfalar> {
    final controllerpage = PageController(
    initialPage: 0,
  );
  @override
  Widget build(BuildContext context) {
    final pageview = PageView(
      controller: controllerpage,
      children: [
        Islerim(),
        kamerapage.Kamera(),
     
      ],
    );
    return   Scaffold(body: pageview) ;
  }
}