import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingAlert extends StatelessWidget {
  final Size screenSize;
  final Color color;
  const LoadingAlert({Key? key, required this.screenSize, this.color = Colors.orange}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.height,
      alignment: Alignment.center,
      child: SpinKitRing(
        size: 100,
        color: color,
      ),
     
    );
  }
}