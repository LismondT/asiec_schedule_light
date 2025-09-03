import 'package:flutter/material.dart';

class AppBarTitle extends StatelessWidget {
  final String title;

  const AppBarTitle({
    super.key,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Text(title,
      style: TextStyle(
        fontWeight: FontWeight.w600
      )
    );
  }
}