import 'package:app4/themes/themes.dart';
import 'package:flutter/material.dart';

class BtnAllConfirmations extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color btnColor;
  final double btnWidth;
  const BtnAllConfirmations({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed, required this.btnColor, required this.btnWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      // onPressed: !registerForm.isValidRegister()
      onPressed: onPressed,
      disabledColor: AppTheme.gray50,
      elevation: 0,
      color: btnColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        height: 45,
        width: btnWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              width: 8,
            ),
            Icon(
              icon ?? null,
              color: Colors.white,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
