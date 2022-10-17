import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';


class BrandingQaira extends StatelessWidget {
  final double width;
  const BrandingQaira({
    Key? key, required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Con el apoyo de:',
          style: TextStyle(
            color: AppTheme.gray50,
            fontSize: width*0.025
          ),
          ),
        Image.asset(
          'assets/logos/logoQaira.jpg',
          width: width*0.1,
          // height: width*0.05,
        )
      ],
    );
  }
}

class BrandingLimaWhite extends StatelessWidget {
  final double width;
  const BrandingLimaWhite({
    Key? key, required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/logos/logoLimaWhite.png',
          width: width*0.1,
          // height: width*0.05,
        )
      ],
    );
  }
}
class BrandingLima extends StatelessWidget {
  final double width;
  final bool center;
  const BrandingLima({
    Key? key, required this.width, this.center = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Image.asset(
          'assets/logos/logoLima.png',
          width: width*0.4,
          // height: width*0.05,
        )
      ],
    );
  }
}
class BrandingApp extends StatelessWidget {
  final double width;
  final bool center;
  const BrandingApp({
    Key? key, required this.width, this.center = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Image.asset(
          'assets/logos/appLogoName.png',
          width: width*0.4,
          // height: width*0.05,
        )
      ],
    );
  }
}
