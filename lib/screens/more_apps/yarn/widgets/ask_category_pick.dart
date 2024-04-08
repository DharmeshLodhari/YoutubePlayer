import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AskCategoryPick extends StatelessWidget {
  List<Map<String, dynamic>> categories = [
    {'category': 'Health', 'icon': SvgPicture.asset("ask/health".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/politics".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/technology".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/education".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/sport".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/travels".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/food".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/finance".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/art_culture".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/relationshi".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/religion".toSVG())},
    {'category': 'Health', 'icon': SvgPicture.asset("ask/fashion".toSVG())},
  ];

  Function(String? category)? onCategoryPick;

  AskCategoryPick({this.onCategoryPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Text(
            'Choose category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 10,
          ),
          Wrap(
            runSpacing: 20,
            spacing: 36,
            children: categories
                .map(
                  (e) => GestureDetector(
                    onTap: () => onCategoryPick!(e['category']),
                    child: Container(
                      height: 90,
                      width: 90,
                      child: e['icon'],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
