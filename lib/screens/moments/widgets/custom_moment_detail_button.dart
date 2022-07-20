import 'package:flutter/material.dart';

class CustomMomentDetailButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final Function()? onPressed;

  const CustomMomentDetailButton(
      {Key? key,
      required this.icon,
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
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white54,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0.0, 0),
                    color: Colors.black.withOpacity(0.6),
                  )
                ],
                borderRadius: BorderRadius.circular(40),
              ),
              child: icon,
            ),
            const SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }
}
