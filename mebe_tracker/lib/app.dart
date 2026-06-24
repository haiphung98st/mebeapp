import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class MeBeApp extends StatelessWidget {
  const MeBeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeBé Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(body: Center(child: Text('MeBé Tracker'))),
    );
  }
}
