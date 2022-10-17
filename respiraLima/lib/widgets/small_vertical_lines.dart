import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';

class SmallVerticalLine extends StatelessWidget {
  final double? height;
  final double? width;
  const SmallVerticalLine({
    Key? key, this.height, this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1),
      height: height ?? 4,
      width: width ?? 1.5,
      decoration:  const BoxDecoration(
          color: AppTheme.gray50,
          borderRadius: BorderRadius.all(Radius.circular(10))
          
        ),
                        
    );
  }
}