import 'package:Slydo/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../data/currency.dart';
import '../../../../utils/util.dart';
import '../../../../widget/curved_btn.dart';

class VariantOverlay extends StatefulWidget {
  final List<Map<String, dynamic>>? variant;
  final Function onClose;
  final Function(int variantId) onAdd;
  final Function(int variantId) onSubtract;
  String? currency;

  VariantOverlay({Key? key, required this.variant, required this.onClose, required this.currency, required this.onAdd, required this.onSubtract}) : super(key: key);

  @override
  State<VariantOverlay> createState() => _VariantOverlayState();
}

class _VariantOverlayState extends State<VariantOverlay> {
  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: black,),
                  onPressed:() {
                    widget.onClose();
                  },
                  color: Colors.white,
                ),
              ),
              Container(
                // margin: EdgeInsets.all(20.0),
                height: 400,
                // height: screenHeight * 0.5,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.variant?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    final item = widget.variant![index];

                    return Padding(
                      padding: widget.variant?.length == 0 ? const EdgeInsets.all(8.0): const EdgeInsets.only(left: 20.0),
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              CachedNetworkImage(
                                imageUrl: item['image'],
                                height: 150,
                                // fit: BoxFit.contain,
                                placeholder: (context, url) => Container(
                                    height: 20.0,
                                    width: 20.0,
                                    child: Center(child: CircularProgressIndicator())),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),

                              const SizedBox(height: 20),
                              Text('Quantity: ${item['quantity']}'),
                              const SizedBox(height: 20),
                              getPriceWidget(item),
                              const SizedBox(height: 20),
                              getTotalPriceWidget(item),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  _buildIncreaseButtonWidget(index),
                                  SizedBox(width: 20),
                                  _buildDecreaseButtonWidget(index, item),

                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getPriceWidget(Map<String, dynamic> item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          worldCurrencies[widget.currency]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(int.parse(item['current_price'])),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget getTotalPriceWidget(Map<String, dynamic> item) {
    var totalPrice =
        int.parse(item['quantity'].toString()) * int.parse(item['current_price']);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Total: ',
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          worldCurrencies[widget.currency]!,
          style: TextStyle(
              color: blackFont,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
        Text(
          moneyDisplayNormalizer(totalPrice),
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildIncreaseButtonWidget(int index) {
    return SizedBox(
      width: 100,
      child: CurvedButton(
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "Add",
        onPressed: () async {
          widget.onAdd(index);
          if(mounted)setState(() {});
        },
      ),
    );
  }

  Widget _buildDecreaseButtonWidget(int index, Map<String, dynamic> item) {
    return SizedBox(
      width: 100,
      child: CurvedButton(
        backgroundColor: mateRed,
        textColor: Colors.white,
        text: "Remove",
        onPressed: () async {
          widget.onSubtract(index);
          setState(() {
            //check if its the quantity is one and if its the only variant in the list
            if(item['quantity'] == 1 && widget.variant?.length == 1){
              widget.onClose;
            }
          });
        },
      ),
    );
  }
}
