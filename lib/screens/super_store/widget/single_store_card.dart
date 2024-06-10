import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:flutter/material.dart';

class SuperStoreSingleCard extends StatelessWidget {
  final Product product;
  // final String? next;
  const SuperStoreSingleCard({super.key, required this.product})
     ;

  @override
  Widget build(BuildContext context) {
    return DisplayProduct(product: product, giveRightPadding: false);
  }
}
