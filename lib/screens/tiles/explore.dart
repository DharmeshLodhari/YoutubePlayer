import 'package:Slydo/locale/app_localization.dart';
import 'package:flutter/material.dart';

class ExploreTile extends StatefulWidget {
  const ExploreTile({super.key});

  @override
  State<ExploreTile> createState() => _ExploreTileState();
}

class _ExploreTileState extends State<ExploreTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
        child: ListTile(
          title: Text(
            AppLocalization.of(context)!.explore,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          leading: const Icon(
            Icons.explore,
            color: Colors.black,
            size: 45,
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/explore');
          },
        ),
      ),
    );
  }
}
