import 'package:flutter/material.dart';

class FoodridgeLogo extends StatelessWidget {
  const FoodridgeLogo({
    super.key,
    this.height = 112,
  });

  /// Login / splash: ~112. App bar / header: ~40.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/foodridge_logo.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
