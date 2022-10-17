

import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';

class SmallBolWithHole extends StatelessWidget {
  final double? radio;
  final double? widthHeight;
  const SmallBolWithHole({
    Key? key, this.radio, this.widthHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radio ?? 8,
      backgroundColor: AppTheme.darkBlue,
      child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(right: 10),
      height: widthHeight ?? 9.5,
      width: widthHeight ?? 9.5,
      decoration:  const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.all(Radius.circular(5))
        ),
                        
    ),               
    );
  }
}