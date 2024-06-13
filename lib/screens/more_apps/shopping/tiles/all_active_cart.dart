import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';

class AllActiveCart extends StatefulWidget {
  const AllActiveCart({super.key});

  @override
  State<AllActiveCart> createState() => _AllActiveCartState();
}

class _AllActiveCartState extends State<AllActiveCart> {
  bool isLoading = false;
  List<SharedCartModel> cartList = [];
  SharedCartModel selectedCart = SharedCartModel();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    fetchCartData();
    super.initState();
  }

  void fetchCartData() async {
    isLoading = true;
    if (mounted) setState(() {});
    final List<SharedCartModel> result = await getCartList();
    cartList.add(SharedCartModel(id: 'my-cart', name: 'My cart'));
    if (result.isNotEmpty) {
      for (SharedCartModel cart in result) {
        cartList.add(cart);
      }
    }
    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Wrap(
            children: [
              Center(
                child: Text(
                  "Active Cart",
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
                  itemCount: cartList.length,
                  itemBuilder: (context, index) {
                    return RadioListTile<SharedCartModel>(
                      contentPadding: EdgeInsets.zero,
                      visualDensity:
                          const VisualDensity(horizontal: 0, vertical: -3),
                      value: cartList[index],
                      groupValue: selectedCart,
                      onChanged: (value) {
                        setState(() {
                          selectedCart = value!;
                        });

                        Future.delayed(const Duration(milliseconds: 500), () {
                          Navigator.pop(context, selectedCart);
                        });
                      },
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(
                        cartList[index].name ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: selectedCart.id == cartList[index].id
                              ? navyBlue
                              : blackFont,
                          fontFamily: "Inter",
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
