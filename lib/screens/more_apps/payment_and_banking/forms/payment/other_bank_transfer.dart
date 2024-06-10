import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/payment/other_bank_transfer/beneficiary_transfer.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/forms/payment/other_bank_transfer/new_beneficiary_transfer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../tiles/other_bank_tab_selection.dart';

// ignore: must_be_immutable
class OtherBankTransfer extends StatefulWidget {
  final dynamic arguments;
  final Function(bool)? callback;

  const OtherBankTransfer({super.key, this.arguments, this.callback});

  // Declare a field that holds the userData.
  @override
  State<OtherBankTransfer> createState() => _OtherBankTransferState();
}

class _OtherBankTransferState extends State<OtherBankTransfer> {
  late UserBloc userBloc;
  late PageController _pageViewController;
  int currentAskTapOnHome = 0;

  @override
  void initState() {
    _pageViewController = PageController(initialPage: 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    final bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 16, vertical: isScreenIsSmall ? 4 : 8),
      child: Column(
        children: [
          _buildTabs(),
          _buildPageView(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        OtherBankTabSelection(
          onTap: (index) {
            currentAskTapOnHome = index;
            _pageViewController.jumpToPage(currentAskTapOnHome);

            if (mounted) setState(() {});
          },
          currentIndex: currentAskTapOnHome,
        ),
        const SizedBox(
          height: 5,
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
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageViewController,
        children: [
          NewBeneficiaryTransfer(
            arguments: widget.arguments,
            callback: widget.callback,
          ),
          BeneficiaryTransfer(
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
