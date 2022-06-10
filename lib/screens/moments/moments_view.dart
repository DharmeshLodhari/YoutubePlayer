import 'package:Slydo/screens/moments/moments_model.dart';
import 'package:flutter/material.dart';

class MomentsView extends StatelessWidget {
  final MomentsModel? momentsModel;
  const MomentsView({Key? key, this.momentsModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text('Moments View'),
    );
  }
}
