import 'package:Slydo/screens/more_apps/payment_and_banking/forms/payment/other_bank_transfer.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/payment/slydo_slydo_transfer.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../tiles/payment_tab_selection.dart';

class SendPayment extends StatefulWidget {
  var arguments;
  final Function(bool)? callback;

  SendPayment({this.arguments, this.callback});

  @override
  State<SendPayment> createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> {
  late PageController _pageViewController;
  int currentAskTapOnHome = 0;
  String? selectedCategoryId;
  bool isQuestionMode = false;
  int count = 0;

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar() as PreferredSizeWidget,
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () async {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            await Future.delayed(Duration(milliseconds: 300));
          }
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Send Payment',
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        SizedBox(
          height: 16,
        ),
        _buildTabs(),
        _buildPageView(),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        PaymentTabSelection(
          onTap: (index) {
            currentAskTapOnHome = index;
            _pageViewController.jumpToPage(currentAskTapOnHome);

            if (mounted) setState(() {});
          },
          currentIndex: currentAskTapOnHome,
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget _buildPageView() {
    return Expanded(
      child: PageView(
        onPageChanged: (currentPage) {
          updateCurrentAskTapOnHome(index: currentPage);
        },
        controller: _pageViewController,
        children: [
          SlydoSlydoTransfer(
            arguments: widget.arguments,
            callback: widget.callback,
          ),
          OtherBankTransfer(
            arguments: widget.arguments,
            callback: widget.callback,
          ),
        ],
      ),
    );
  }

  void updateCurrentAskTapOnHome({required int index}) {
    setState(() {
      currentAskTapOnHome = index;
    });
  }
}
