import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';

import '../../../../../data/database_helper.dart';
import '../../../../../utils/slydo_app_icon_icons.dart';
import '../../../../../widget/customized_dropdown_field.dart';
import '../../models/VirtualAccount.dart';
import '../../payment_and_banking_auth.dart';

class UpgradeAccount extends StatefulWidget {
  const UpgradeAccount({Key? key}) : super(key: key);

  @override
  State<UpgradeAccount> createState() => _UpgradeAccountState();
}

class _UpgradeAccountState extends State<UpgradeAccount> {
  bool isLoading = false;
  bool isAccountExist = false;
  String? _selectedTier;
  String? _currentTier;
  List<String> tiers = [];
  VirtualAccount? virtualAccount;

  @override
  void initState() {
    super.initState();
    getSlydoAccount();
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
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
        "Upgrade Account Tier",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar() as PreferredSizeWidget?,
      body: Column(
        children: [
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                // getTierSelection(),
                getTierDropDown(),
                SizedBox(height: 16),
                getUpdateTierButton(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getTierDropDown() {
    debugPrint("Current ==> $_currentTier");

    if (_currentTier == "3") {
      return Container();
    }

    return CustomizedDropDownField(
      title: "Select Tier",
      child: ListTile(
        dense: true,
        title: Text(
          _selectedTier ?? "",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          selectTier();
        },
      ),
    );
  }

  void selectTier() async {
    if (_currentTier == "1") {
      tiers = ["Tier 2", "Tier 3"];
    } else if (_currentTier == "2") {
      tiers = ["Tier 3"];
    } else {
      tiers = [];
    }

    final pressedCondition = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: tiers.map<Widget>((item) {
                          if (_selectedTier == item) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Text(
                                      item,
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, item);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              item,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, item);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCondition != null) {
      _selectedTier = pressedCondition;
      setState(() {});
    }
  }

  Widget getUpdateTierButton() {
    if (_currentTier == "3") {
      return Container();
    }

    return CurvedButton(
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Update",
      onPressed: () {
        Navigator.of(context).pushNamed("/add-bvn-number", arguments: {
          "account": virtualAccount,
          "selected_tier": _selectedTier
        });
      },
    );
  }

  void getSlydoAccount() async {
    isLoading = true;
    setState(() {});
    bool isFromServer = false;

    virtualAccount = await DatabaseHelper().getVirtualAccount();
    if (virtualAccount == null) {
      virtualAccount = await PaymentAndBankingAuth().getVirtualAccountDetail();
      isFromServer = true;
    }

    isLoading = false;
    if (virtualAccount == null) {
      isAccountExist = false;
      Navigator.of(context).pushNamed("/add-bvn-number");
    } else {
      isAccountExist = true;
      if (isFromServer) {
        await DatabaseHelper().saveVirtualAccount(virtualAccount!);
      }
    }

    _currentTier = virtualAccount?.accountTier?.tierType;

    debugPrint("CURRENT TIER => $_currentTier");
    if (_currentTier == "1") {
      _selectedTier = "Tier 2";
    } else if (_currentTier == "2") {
      _selectedTier = "Tier 3";
    }

    /// TODO: REMOVE THIS COMMENT AND LINES WHEN IMPLEMENTATION DONE FOR KYC
    // isKYCInProcess = true;
    // isAccountExist = false;
    if (mounted) setState(() {});
  }
}
