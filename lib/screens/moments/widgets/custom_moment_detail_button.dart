import 'package:flutter/material.dart';

class CustomMomentDetailButton extends StatelessWidget {
  final String text;
  final bool iconEnabled;
  final IconData iconData;
  final Function()? onPressed;

  const CustomMomentDetailButton(
      {Key? key,
      required this.iconData,
      required this.iconEnabled,
      required this.text,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white38,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0.0, 0),
                    color: Colors.black.withOpacity(0.6),
                  ),
                ],
                // borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                iconData,
                size: 20,
                color: iconEnabled ? Colors.white : Colors.white38,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
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
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
