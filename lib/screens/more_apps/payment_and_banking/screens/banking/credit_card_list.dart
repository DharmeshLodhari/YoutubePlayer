import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:Slydo/widget/vertical_list_item.dart';

class CreditCardList extends StatefulWidget {
  @override
  _CreditCardListState createState() => _CreditCardListState();
}

class _CreditCardListState extends State<CreditCardList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List bankAccountList = [
    BankAccount(
        isDefault: true,
        bankAvatar:
            'https://res.cloudinary.com/depbpm8dn/image/upload/v1643984424/Rectangle_96_mztco3.png',
        bankName: 'Zenith',
        accountName: 'Ibukunoluwa Oladipo',
        uuid: 'franklin-uuid-13',
        accountNumber: '0179184481'),
    BankAccount(
        isDefault: false,
        bankAvatar:
            'https://res.cloudinary.com/depbpm8dn/image/upload/v1643984442/Rectangle_96_z9woru.png',
        bankName: 'Gtbank',
        accountName: 'Franklin Oladipo',
        uuid: 'franklin-uuid-12',
        accountNumber: '0179146531'),
  ];

  // //slidable tile
  SlidableController? _slideController;

  @override
  void initState() {
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: _buildBankAccountList(),
      ),
    );
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
        AppLocalization.of(context)!.creditCards,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        openGraphBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget openGraphBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        //for adding new account
        Navigator.of(context).pushNamed('/card-payment-page');
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildBankAccountList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16),
      //+1 for progressbar
      itemCount: bankAccountList.length,
      itemBuilder: (BuildContext context, int index) {
        return _getSlidableWithLists(
            context,
            bankAccountTile(
              account: bankAccountList[index],
            ),
            bankAccountList[index]);
      },
    );
  }

  Widget bankAccountTile({required BankAccount account}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: account.isDefault! ? true : false,
          title: getTitle(account: account),
          subtitle: getSubtitle(account: account),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed("/photo-viewer", arguments: account.bankAvatar);
            },
            child: CachedNetworkImage(
              imageUrl: account.bankAvatar!,
              height: 48,
              width: 48,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              placeholder: (context, url) => account.bankAvatar == ""
                  ? Icon(
                      Icons.account_balance,
                      size: 45,
                      color: navyBlue,
                    )
                  : CircularLoadingIndicator(),
              errorWidget: imageErrorWidget,
            ),
          ),
        ),
      ),
    );
  }

  Widget getTitle({required BankAccount account}) {
    if (account.isDefault!) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Text(
            account.bankName!,
            maxLines: 1,
            style: TextStyle(
                color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      );
    }
    return Text(
      account.bankName!,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getSubtitle({required BankAccount account}) {
    if (account.isDefault!) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 4,
          ),
          Text(
            getFormattedAccountNumber(
                accountNumber: account.accountNumber!.toString()),
            style: TextStyle(color: darkGrey, fontSize: 12),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            AppLocalization.of(context)!.defaultMsg,
            style: TextStyle(color: darkGrey, fontSize: 12),
          ),
          SizedBox(
            height: 4,
          ),
        ],
      );
    }
    return Text(
      getFormattedAccountNumber(
          accountNumber: account.accountNumber!.toString()),
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget bankAccountTile, BankAccount account) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(bankAccountTile),
      actions: listActionSlideActions(account: account),
      secondaryActions: listSecondaryActions(account: account),
    );
  }

  List<Widget> listSecondaryActions({required BankAccount account}) {
    return [
      SlideActionButton(
          backgroundColor: naturalGreen,
          icon: Icons.device_hub,
          onTap: account.isDefault!
              ? () {
                  showToast(
                      message: AppLocalization.of(context)!
                          .thisAccountIsAlreadyDefaultAccount);
                }
              : () {
                  // updateBankAccount(account);
                },
          title: account.isDefault!
              ? AppLocalization.of(context)!.defaultMsg
              : AppLocalization.of(context)!.makeDefault,
          slideController: _slideController),
    ];
  }

  List<Widget> listActionSlideActions({BankAccount? account}) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.remove,
          onTap: () {
            // deleteBankAccount(account);
          },
          title: AppLocalization.of(context)!.delete,
          slideController: _slideController),
    ];
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  @override
  void dispose() {
    super.dispose();
  }
}
