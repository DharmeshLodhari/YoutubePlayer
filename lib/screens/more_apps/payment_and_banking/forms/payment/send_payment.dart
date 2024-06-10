import 'package:Slydo/screens/more_apps/payment_and_banking/forms/payment/other_bank_transfer.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/payment/slydo_slydo_transfer.dart';
import 'package:Slydo/screens/scan_qr_code.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/tab_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SendPayment extends StatefulWidget {
  final dynamic arguments;
  final Function(bool)? callback;

  const SendPayment({super.key, this.arguments, this.callback});

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
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar() as PreferredSizeWidget,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 10,
      centerTitle: false,
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
            await Future.delayed(const Duration(milliseconds: 300));
          }
          Navigator.pop(context, "back pressed");
        },
      ),
      title: Text(
        'Send Payment',
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        if (currentAskTapOnHome == 0)
          GestureDetector(
            onTap: () {
              NavigationUtil.push(context,
                  screen: QRCodeView(arguments: const {'isRequest': false}));
            },
            child: SvgPicture.asset(
              'assets/images/rider/scan_qr.svg',
              width: 20,
              height: 20,
            ),
          ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        const SizedBox(
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
        TabSelection(
          onTap: (index) {
            currentAskTapOnHome = index;
            _pageViewController.jumpToPage(currentAskTapOnHome);

            if (mounted) setState(() {});
          },
          currentIndex: currentAskTapOnHome,
          firstTab: 'Slydo Account',
          secondTab: 'Bank Transfer',
        ),
        const SizedBox(
          height: 10,
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
