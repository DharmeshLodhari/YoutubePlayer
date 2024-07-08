import 'package:Slydo/constant.dart';
import 'package:Slydo/screens/super_store/super_store_home.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/widget/permission_protection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../locator.dart';
import '../routes/route_constants.dart';
import '../services/app_config_bloc.dart';
import '../utils/navigation_util.dart';
import '../utils/slydo_app_icon_icons.dart';
import '../utils/util.dart';
import '../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../widget/dialog.dart';
import '../widget/rounded_background_icon.dart';
import 'connection_module/channels_list.dart';
import 'connection_module/connections_dashboard.dart';
import 'moments/screens/create_moment_screen.dart';
import 'moments/screens/moments_screen.dart';
import 'more_apps/payment_link/payment_link.dart';
import 'more_apps/shopping/screens/my_products.dart';
import 'more_apps/shopping/screens/my_services.dart';
import 'more_apps/yarn/add_or_edit_yarn_screen.dart';
import 'more_apps/yarn/models/share_as_yarn_model.dart';
import 'more_apps/yarn/yarn_dashboard.dart';
import 'more_apps/yarn/yarn_dashboard_bloc.dart';

class HomeQuickView extends StatefulWidget {
  final dynamic arguments;

  const HomeQuickView({this.arguments, super.key});

  @override
  State<HomeQuickView> createState() => _HomeQuickViewState();
}

class _HomeQuickViewState extends State<HomeQuickView> {
  int? count = 0;
  String? next = "";
  String? previous = "";
  bool isLoading = false;
  List<Widget> results = [];
  bool noItemInList = false;
  bool isSearchIsEmpty = true;
  String autoCompleteSearchText = "";
  late AppLocalization appLocalization;
  AppConfigurationModel? appConfigurationModel;
  final ScrollController _scrollController = ScrollController();
  TextEditingController searchItemTextController = TextEditingController();

  String appBarTitle = "";
  List<Map<String, String>> selectedList = [];
  List<Map<String, String>> filteredList = [];
  late YarnDashboardBloc yarnDashboardBloc;

  late UserBloc userBloc;

  @override
  void initState() {
    super.initState();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
    appBarTitle = widget.arguments['view'];

    checkForListToDisplay();

    searchItemTextController.addListener(() {
      filterList(searchItemTextController.text);
    });
  }

  void checkForListToDisplay() {
    final List<Map<String, String>> payment = [
      {
        'imagePath': 'home/transaction',
        'title': ProtectionPermission.transaction,
        'ForReadPermission': '2', // 1 : Read, 2 : Write
      },
      {
        'imagePath': 'home/send',
        'title': ProtectionPermission.sendMoney,
        'ForReadPermission': '1',
      },
      {
        'imagePath': 'home/request',
        'title': ProtectionPermission.requestMoney,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/payment_link',
        'title': ProtectionPermission.paymentLinks,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/wallet',
        'title': ProtectionPermission.wallet,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/credit_card',
        'title': ProtectionPermission.creditCard,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/utility',
        'title': ProtectionPermission.utility,
        'ForReadPermission': '2',
      },
    ];
    final List<Map<String, String>> business = [
      {
        'imagePath': 'home/product',
        'title': ProtectionPermission.product,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/service',
        'title': ProtectionPermission.services,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/invoice',
        'title': ProtectionPermission.invoice,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/contract',
        'title': ProtectionPermission.contract,
        'ForReadPermission': '2',
      },
    ];
    final List<Map<String, String>> socials = [
      {
        'imagePath': 'home/chat_social',
        'title': ProtectionPermission.chat,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/inbox_social',
        'title': ProtectionPermission.inbox,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/yarn',
        'title': ProtectionPermission.yarn,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/moment',
        'title': ProtectionPermission.moment,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/blog',
        'title': ProtectionPermission.blog,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/channel',
        'title': ProtectionPermission.channel,
        'ForReadPermission': '2',
      },
    ];
    final List<Map<String, String>> lifestyle = [
      {
        'imagePath': 'home/order',
        'title': ProtectionPermission.orders,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/super_store',
        'title': ProtectionPermission.superStore,
        'ForReadPermission': '2',
      },
      {
        'imagePath': 'home/service',
        'title': ProtectionPermission.servicesHub,
        'ForReadPermission': '2',
      },
    ];
    final List<Map<String, String>> create = [
      {
        'imagePath': 'home/yarn',
        'title': ProtectionPermission.yarn,
        'ForReadPermission': '1',
      },
      {
        'imagePath': 'home/moment',
        'title': ProtectionPermission.moment,
        'ForReadPermission': '1',
      },
      {
        'imagePath': 'home/product',
        'title': ProtectionPermission.product,
        'ForReadPermission': '1',
      },
      {
        'imagePath': 'home/service',
        'title': ProtectionPermission.services,
        'ForReadPermission': '1',
      },
      {
        'imagePath': 'home/inbox',
        'title': ProtectionPermission.inbox,
        'ForReadPermission': '1',
      },
      {
        'imagePath': 'home/blog',
        'title': ProtectionPermission.blog,
        'ForReadPermission': '1',
      },
      {
        'imagePath': 'home/contract',
        'title': ProtectionPermission.contract,
        'ForReadPermission': '1',
      },
      {
        'imagePath': 'home/invoice',
        'title': ProtectionPermission.invoice,
        'ForReadPermission': '1',
      },
      {
        'imagePath': 'home/channel',
        'title': ProtectionPermission.channel,
        'ForReadPermission': '1',
      },
      {
        'imagePath': 'home/group',
        'title': ProtectionPermission.group,
        'ForReadPermission': '1',
      },
    ];

    switch (appBarTitle) {
      case "Payment":
        selectedList = payment;
        break;
      case 'Business':
        selectedList = business;
        break;
      case 'Socials':
        selectedList = socials;
        break;
      case 'Lifestyles':
        selectedList = lifestyle;
        break;
      case 'Create':
        selectedList = create;
        break;

      default:
        // Handle the default case (if any)
        debugPrint('Tapped on an unknown shortcut');
    }
  }

  void _isRefreshing() {
    count = 0;
    next = "";
    previous = "";
    results.clear();
    isLoading = false;
    noItemInList = false;
  }

  @override
  void dispose() {
    searchItemTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: Column(
        children: [
          const SizedBox(height: 6),
          // searchBox(),
          // SizedBox(height: 16),
          Expanded(
            child: _displayShortcutCard(
                filteredList.isNotEmpty ? filteredList : selectedList),
          ),
        ],
      ),
    );
  }

  Widget searchBox() {
    try {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionHandleColor: navyBlue,
            ),
          ),
          child: TextFormField(
            autofocus: true,
            controller: searchItemTextController,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
            cursorWidth: 1.5,
            cursorColor: navyBlue,
            decoration: InputDecoration(
              hintText: AppLocalization.of(context)!.searchHomeQuickViewHint,
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 12),
              ),
              suffixIcon: searchIcon(),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: dividerColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: navyBlue,
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: dividerColor,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: dividerColor,
                  width: 1.0,
                ),
              ),
            ),
            onFieldSubmitted: (val) {
              filterList(val);
            },
          ),
        ),
      );
    } catch (e) {
      return Container();
    }
  }

  Widget searchIcon() {
    return IconButton(
      icon: Icon(
        SlydoAppIcon.search,
        color: darkGrey,
        size: 16,
      ),
      onPressed: () {
        if (mounted) {
          setState(() => _isRefreshing());

          FocusScope.of(context).unfocus();
        }
      },
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
      title: Text(
        appBarTitle,
        style: TextStyle(
            color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _displayShortcutCard(List<Map<String, String>> shortcuts) {
    return SingleChildScrollView(
      child: Column(
        // padding: EdgeInsets.zero,
        children: List.generate(
          (shortcuts.length / 2).ceil(),
          (index) {
            final startIndex = index * 2;
            final endIndex = startIndex + 2;
            final pairShortcuts = shortcuts.sublist(
              startIndex,
              endIndex > shortcuts.length ? shortcuts.length : endIndex,
            );

            if (pairShortcuts.length == 1) {
              // Add an empty space for the second item
              pairShortcuts.add({});
            }

            return Row(
              children: pairShortcuts.map((shortcut) {
                if (shortcut.isEmpty) {
                  // Return an empty space (SizedBox)
                  return const Expanded(
                    child: SizedBox(),
                  );
                } else {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: shortcutView(
                        shortcut['imagePath']!,
                        shortcut['title']!,
                        shortcut['ForReadPermission']!,
                      ),
                    ),
                  );
                }
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget shortcutView(
      String imagePath, String title, String forReadPermission) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: greyBorderColor),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: GestureDetector(
        onTap: () {
          if (appBarTitle == 'Create') {
            onClickShortcutCreate(title);
          } else {
            onClickShortcut(title);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PermissionProtectionWidget(
              permissionName: title,
              isShowLock: true,
              position: 10,
              isLockForRead: forReadPermission,
              child: Row(
                children: [
                  SvgPicture.asset(
                    imagePath.toSVG(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onClickShortcut(String title) {
    switch (title) {
      case ProtectionPermission.transaction:
        BottomSheetPassCode(
            context: context,
            isValidCallback: () {
              Navigator.of(context)
                  .pushNamed(Routes.TRANSACTIONS, arguments: {'page': 0});
            },
            cancelCallBack: () {
              Navigator.pop(context);
            });
        break;
      case ProtectionPermission.sendMoney:
        Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
            arguments: <String, bool>{'isFromProfile': true});
        break;
      case ProtectionPermission.requestMoney:
        Navigator.pushNamed(context, Routes.ACCOUNTS);
        break;
      case ProtectionPermission.paymentLinks:
        BottomSheetPassCode(
            context: context,
            isValidCallback: () {
              NavigationUtil.push(context, screen: PaymentLink());
            },
            cancelCallBack: () {
              Navigator.pop(context);
            });
        break;
      case ProtectionPermission.wallet:
        Navigator.of(context).pushNamed(Routes.ADD_MONEY_TO_SLYDO_ONE);
        break;
      case ProtectionPermission.creditCard:
        if (appConfigurationModel?.enableAddUserCreditCard == true) {
          Navigator.of(context).pushNamed(Routes.CREDIT_CARD_OPTION_SELECTION);
        } else {
          showToast(message: 'Coming soon.');
        }
        break;
      case ProtectionPermission.utility:
        if (appConfigurationModel?.enableUtility == true) {
          Navigator.pushNamed(context, Routes.UTILITY_DASHBOARD);
        } else {
          showToast(message: 'Coming soon.');
        }
        break;
      case ProtectionPermission.product:
        NavigationUtil.push(context, screen: const MyProducts());
        break;
      case ProtectionPermission.services:
        NavigationUtil.push(context, screen: const MyServices());
        break;
      case ProtectionPermission.invoice:
        if (appConfigurationModel?.enableInvoice == true) {
          Navigator.pop(context);
          Navigator.pushNamed(context, Routes.INVOICE_SCREEN);
        } else {
          showToast(message: 'Coming soon');
        }
        break;
      case ProtectionPermission.contract:
        if (appConfigurationModel?.enableContract == true) {
          Navigator.pop(context);
          Navigator.pushNamed(context, Routes.CONTRACT_SCREEN);
        } else {
          showToast(message: 'Coming soon');
        }
        break;
      case ProtectionPermission.chat:
        NavigationUtil.push(context, screen: const ConnectionDashboard());
        break;
      case ProtectionPermission.inbox:
        Navigator.of(context).pushNamed(Routes.MESSAGE_LIST);
        break;
      case ProtectionPermission.yarn:
        NavigationUtil.push(context, screen: const YarnDashboard());
        break;
      case ProtectionPermission.moment:
        NavigationUtil.push(context, screen: const MomentsScreen());
        break;
      case ProtectionPermission.blog:
        // if (appConfigurationModel?.enableSuperBlog == true) {
        NavigationUtil.pushNamed(
          context,
          routeName: Routes.SUPER_BLOG,
        );
        // } else {
        //   showToast(message: 'Feature not available at the moment');
        // }
        break;
      case ProtectionPermission.channel:
        NavigationUtil.push(
          context,
          screen: const ChannelsList(),
        );
        break;
      case ProtectionPermission.orders:
        Navigator.pushNamed(context, Routes.ORDER_LIST);
        break;
      case ProtectionPermission.superStore:
        NavigationUtil.push(context, screen: const SuperStoreHome());
        break;
      case ProtectionPermission.servicesHub:
        Navigator.pushNamed(context, Routes.SUPER_HUB, arguments: {'page': 0});
        break;
      default:
        // Handle the default case (if any)
        debugPrint('Tapped on an unknown shortcut');
    }
  }

  void onClickShortcutCreate(String title) {
    switch (title) {
      case ProtectionPermission.yarn:
        NavigationUtil.push(context,
            screen: AddOrEditYarn(
              askCategories: yarnDashboardBloc.yarnCategories,
              shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
              isYarn: true,
              passedCategory: '',
            ));
        break;
      case ProtectionPermission.moment:
        NavigationUtil.push(context, screen: const CreateMediaMomentScreen());
        break;
      case ProtectionPermission.product:
        if (userBloc.user.type!.toLowerCase() == 'user') {
          showUpgradeDialog(context);
        } else {
          Navigator.pushNamed(context, Routes.ADD_PRODUCT,
              arguments: {"channelUsername": ""});
        }
        break;
      case ProtectionPermission.services:
        if (userBloc.user.type!.toLowerCase() == 'user') {
          showUpgradeDialog(context);
        } else {
          Navigator.pushNamed(context, Routes.ADD_SERVICE);
        }
        break;
      case ProtectionPermission.inbox:
        Navigator.of(context).pushNamed(Routes.MESSAGE_LIST);

        break;
      case ProtectionPermission.blog:
        Navigator.of(context).pushNamed(Routes.CREATE_BLOG);
        // showToast(message: 'Coming soon');
        break;
      case ProtectionPermission.invoice:
        if (appConfigurationModel?.enableInvoice == true) {
          Navigator.pop(context);
          Navigator.pushNamed(context, Routes.INVOICE_SCREEN);
        } else {
          showToast(message: 'Coming soon');
        }
        break;
      case ProtectionPermission.contract:
        if (appConfigurationModel?.enableContract == true) {
          Navigator.pop(context);
          Navigator.pushNamed(context, Routes.CONTRACT_SCREEN);
        } else {
          showToast(message: 'Coming soon');
        }
        break;
      case ProtectionPermission.channel:
        // if (appConfigurationModel != null &&
        //     appConfigurationModel!.enableGroupChat == true) {
        Navigator.of(context).pushNamed(Routes.SELECT_USER_FOR_GROUP,
            arguments: {"create": "channel"});
        // }
        break;
      case ProtectionPermission.group:
        // if (appConfigurationModel != null &&
        //     appConfigurationModel!.enableGroupChat == true) {
        Navigator.of(context).pushNamed(Routes.SELECT_USER_FOR_GROUP,
            arguments: {"create": "group"});
        // }
        break;
      default:
        // Handle the default case (if any)
        debugPrint('Tapped on an unknown shortcut');
    }
  }

  Future<void> showUpgradeDialog(BuildContext context) async {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: naturalGreen,
      title: AppLocalization.of(context)!.upgrade,
      actionTwoText: AppLocalization.of(context)!.upgrade,
      actionOneText: AppLocalization.of(context)!.cancel,
      description: AppLocalization.of(context)!.upgradeHomeMsg,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 43,
        height: 43,
        icon: Icon(
          Icons.check_circle_sharp,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      rightButtonOnPressed: () {
        Navigator.of(context).pushNamed(Routes.PRE_ACCOUNT_UPGRADE);
      },
    );
  }

  void filterList(String searchText) {
    setState(() {
      filteredList = selectedList
          .where((item) =>
              item['title']!.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }
}
