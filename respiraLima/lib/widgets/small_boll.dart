


import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';

class SmallBoll extends StatelessWidget {
  final double? heightWidth;
  const SmallBoll({
    Key? key, this.heightWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 10),
      height: heightWidth ?? 15,
      width: heightWidth ?? 15,
      decoration:  const BoxDecoration(
          color: AppTheme.darkBlue,
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
                        
    );
  }
}
