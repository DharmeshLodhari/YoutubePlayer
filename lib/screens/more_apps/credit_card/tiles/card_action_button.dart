import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardActionButton extends StatelessWidget {
  final String iconAsset;
  final String label;
  final Function()? onPressed;

   const CardActionButton({Key? key,
    required this.iconAsset,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(
            height: 25,
            width: 25,
            child: SvgPicture.asset(
              iconAsset,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: navyBlue, // Use 'Colors.blue' or your preferred color
            ),
          ),
        ],
      ),
    );
  }
}

class CardAction {
  final String iconAsset;
  final String label;
  final Function()? onPressed;

  const CardAction({
    required this.iconAsset,
    required this.label,
    required this.onPressed,
  });
}