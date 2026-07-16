import 'package:flutter/material.dart';

import '../layouts/master_screen.dart';

Widget placeholderScreen(String title, String content, {String? subtitle}) {
  return MasterScreen(title: title, subtitle: subtitle, child: Center(child: Text(content)));
}
