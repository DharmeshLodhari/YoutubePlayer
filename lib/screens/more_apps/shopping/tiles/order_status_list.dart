import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';

class OrderStatusList extends StatefulWidget {
  final String orderId;

  const OrderStatusList({super.key, required this.orderId});

  @override
  State<OrderStatusList> createState() => _OrderStatusListState();
}

class _OrderStatusListState extends State<OrderStatusList> {
  bool isLoading = false;
  List<SharedCartModel> statusList = [];
  SharedCartModel selectedCart = SharedCartModel();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    statusList = [
      SharedCartModel(id: 'awaiting payment', name: 'Awaiting payment'),
      SharedCartModel(id: 'canceled', name: 'Canceled'),
      SharedCartModel(id: 'completed', name: 'Completed'),
      SharedCartModel(id: 'on hold', name: 'On Hold'),
      SharedCartModel(id: 'processing', name: 'Processing'),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Wrap(
            children: [
              Center(
                child: Text(
                  "Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w700,
                    color: blackFont,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Divider(
                color: dividerColor,
                thickness: 1,
              ),
              const SizedBox(height: 20),
              if (isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Center(
                    child: CircularLoadingIndicator(),
                  ),
                )
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: _scrollController,
                  itemCount: statusList.length,
                  itemBuilder: (context, index) {
                    return RadioListTile<SharedCartModel>(
                      activeColor: navyBlue,
                      contentPadding: EdgeInsets.zero,
                      visualDensity:
                          const VisualDensity(horizontal: 0, vertical: -3),
                      value: statusList[index],
                      groupValue: selectedCart,
                      onChanged: (value) {
                        setState(() {
                          selectedCart = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(
                        statusList[index].name ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: selectedCart.id == statusList[index].id
                              ? navyBlue
                              : blackFont,
                          fontFamily: "Inter",
                        ),
                      ),
                    );
                  },
                ),
              getSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: CurvedButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.ORDER_UPDATED,
              arguments: {"orderId": widget.orderId});
        },
        // onPressed: isAPILoading
        //     ? () {}
        //     : () async {
        //   FocusScope.of(context).unfocus();
        //
        //   await goToGeneratePage();
        // },
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: "Save",
        // isLoading: isAPILoading,
      ),
    );
  }
}
