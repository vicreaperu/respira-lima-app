import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';

class BtnNavigationMode extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback callback;
  final bool isFocus;
  const BtnNavigationMode({
    Key? key,
    required this.name,
    required this.icon,
    required this.callback,
    required this.isFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color colorBack = isFocus ? AppTheme.primaryBlue : AppTheme.white;
    final Color color = isFocus ? AppTheme.white : AppTheme.black;
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: colorBack,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: const [
          BoxShadow(color: AppTheme.gray30, blurRadius: 1, spreadRadius: 1)
        ],
      ),
      child: MaterialButton(
        onPressed: callback,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color,),
            const SizedBox(
              width: 7,
            ),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

