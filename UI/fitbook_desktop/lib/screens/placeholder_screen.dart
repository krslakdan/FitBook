import 'package:flutter/material.dart';

import '../layouts/master_screen.dart';

Widget placeholderScreen(String title, String content) {
  return MasterScreen(title: title, child: Center(child: Text(content)));
}
