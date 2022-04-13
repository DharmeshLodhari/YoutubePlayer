import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';

import '../../../../../data/database_helper.dart';
import '../../../../../utils/util.dart';
import '../../../../../widget/curved_btn.dart';
import '../../models/VirtualAccount.dart';
import '../../payment_and_banking_auth.dart';
import 'models/kyc_model.dart';

class UserKyc extends StatefulWidget {
  final KycModel kycModel;
  const UserKyc({Key? key, required this.kycModel}) : super(key: key);

  @override
  State<UserKyc> createState() => _UserKycState();
}

class _UserKycState extends State<UserKyc> {
  bool isLoading = true;
  String? userTier;
  VirtualAccount? virtualAccount;

  @override
  void initState() {
    super.initState();
    getUserTier();
  }

  getUserTier() async {
    bool isFromServer = false;

    virtualAccount = await DatabaseHelper().getVirtualAccount();

    if (virtualAccount == null) {
      virtualAccount = await PaymentAndBankingAuth().getVirtualAccountDetail();
      isFromServer = true;
    }

    if (isFromServer) {
      await DatabaseHelper().saveVirtualAccount(virtualAccount!);
    }

    userTier = virtualAccount?.accountTier?.tierType;
    isLoading = false;
    if (mounted) setState(() {});
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.kycDetails,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar() as PreferredSizeWidget?,
      body: SafeArea(
        child: !isLoading
            ? Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.all(8.0),
                    shadowColor: dividerColor,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: dividerColor, width: 0.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          transactionOrKycDetailTile(
                            Icons.description_outlined,
                            AppLocalization.of(context)!.bvnStatus,
                            widget.kycModel.bvnResult ?? '----',
                          ),
                          transactionOrKycDetailTile(
                            Icons.event_note,
                            AppLocalization.of(context)!.documentResult,
                            widget.kycModel.documentResult ?? '----',
                          ),
                          transactionOrKycDetailTile(
                            Icons.receipt_long_outlined,
                            AppLocalization.of(context)!.remark,
                            widget.kycModel.verificationNote ?? '----',
                          ),
                        ],
                      ),
                    ),
                  ),
                  userTier == '3' &&
                          widget.kycModel.bvnResult == 'Successful' &&
                          widget.kycModel.documentResult == 'Successful'
                      ? SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CurvedButton(
                            text: 'Upgrade Account',
                            onPressed: () {
                              Navigator.pushNamed(context, '/upgrade-account');
                            },
                          ),
                        ),
                ],
              )
            : Center(child: CircularLoadingIndicator()),
      ),
    );
  }
}
