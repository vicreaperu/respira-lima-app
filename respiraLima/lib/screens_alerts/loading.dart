import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingAlert extends StatelessWidget {
  final Size screenSize;
  const LoadingAlert({Key? key, required this.screenSize}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.height,
      alignment: Alignment.center,
      child: const SpinKitRing(
        size: 100,
        color: Colors.orange,
      ),
     
    );
  }
}