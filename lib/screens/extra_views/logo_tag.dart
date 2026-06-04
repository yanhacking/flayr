import 'package:flutter/material.dart';
import 'package:untitled/utilities/const.dart';

class LogoTag extends StatelessWidget {
  final bool? isWhite;
  final double? width;

  const LogoTag({Key? key, this.isWhite = false, this.width = 100}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double fontSize = (width ?? 100) * 0.42;
    return ShaderMask(
      shaderCallback: (bounds) => flayrGradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        'FLAYR',
        style: TextStyle(
          fontFamily: 'gilroy_extrabold',
          fontSize: fontSize,
          letterSpacing: fontSize * 0.06,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Compact logo for navigation bars
class LogoTagSmall extends StatelessWidget {
  const LogoTagSmall({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => flayrGradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: const Text(
        'FLAYR',
        style: TextStyle(
          fontFamily: 'gilroy_extrabold',
          fontSize: 22,
          letterSpacing: 2,
          color: Colors.white,
        ),
      ),
    );
  }
}
