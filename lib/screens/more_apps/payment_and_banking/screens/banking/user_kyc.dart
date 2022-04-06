import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';

import '../../../../../data/database_helper.dart';
import '../../../../../utils/util.dart';
import '../../../../../widget/curved_btn.dart';
import '../../models/VirtualAccount.dart';
import '../../payment_and_banking_auth.dart';
import '../../tiles/transaction.dart';
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
    virtualAccount = await DatabaseHelper().getVirtualAccount();

    if (virtualAccount == null) {
      virtualAccount = await PaymentAndBankingAuth().getVirtualAccountDetail();
    }

    userTier = virtualAccount?.accountTier?.tierType;
    print('USER TIER::: $userTier');
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
        'KYC Details',
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
                            'BVN Status',
                            widget.kycModel.bvnResult ?? '----',
                          ),
                          transactionOrKycDetailTile(
                            Icons.event_note,
                            'Document result',
                            widget.kycModel.documentResult ?? '----',
                          ),
                          transactionOrKycDetailTile(
                            Icons.receipt_long_outlined,
                            'Verification note',
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
