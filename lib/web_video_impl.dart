// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

final _registeredViews = <String>{};

Widget buildWebVideo(String src, {required double aspectRatio}) {
  final viewId = 'gcmp-video-${src.hashCode}';
  if (!_registeredViews.contains(viewId)) {
    _registeredViews.add(viewId);
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int id) {
      return html.VideoElement()
        ..src = src
        ..poster = 'demo_poster.png'
        ..preload = 'metadata'
        ..controls = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'contain'
        ..style.background = '#0A0A18';
    });
  }
  return AspectRatio(
    aspectRatio: aspectRatio,
    child: HtmlElementView(viewType: viewId),
  );
}
