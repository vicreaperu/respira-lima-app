import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';

class BtnNavigationWay extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback callback;
  final Color btnColor;
  const BtnNavigationWay({
    Key? key,
    required this.name,
    required this.icon,
    required this.callback, 
    required this.btnColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: const [
          BoxShadow(color: AppTheme.gray30, blurRadius: 1, spreadRadius: 2)
        ],
      ),
      child: MaterialButton(
        onPressed: callback,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
