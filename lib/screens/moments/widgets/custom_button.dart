import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class CustomButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final Function()? onPressed;

  const CustomButton(this.icon, this.text, {Key? key, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                )
              ],
            ),
            child: icon,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  offset: Offset(0.0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }
}
