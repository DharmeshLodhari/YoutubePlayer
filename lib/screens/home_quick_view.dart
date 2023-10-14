import 'package:Slydo/screens/super_store/super_store.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../locator.dart';
import '../routes/route_constants.dart';
import '../services/app_config_bloc.dart';
import '../utils/colors.dart';
import '../utils/navigation_util.dart';
import '../utils/slydo_app_icon_icons.dart';
import '../utils/util.dart';
import '../widget/LoadingIndicator.dart';
import '../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../widget/dialog.dart';
import '../widget/noItemInList.dart';
import '../widget/rounded_background_icon.dart';
import 'connection_module/connections_dashboard.dart';
import 'moments/screens/create_moment_screen.dart';
import 'moments/screens/moments_screen.dart';
import 'more_apps/payment_link/payment_link.dart';
import 'more_apps/shopping/screens/my_products.dart';
import 'more_apps/shopping/screens/my_services.dart';
import 'more_apps/super_blog/super_blog.dart';
import 'more_apps/yarn/add_or_edit_yarn_screen.dart';
import 'more_apps/yarn/models/share_as_yarn_model.dart';
import 'more_apps/yarn/yarn_dashboard.dart';
import 'more_apps/yarn/yarn_dashboard_bloc.dart';

class HomeQuickView extends StatefulWidget {
  final arguments;

  const HomeQuickView({this.arguments, Key? key}) : super(key: key);

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
  ScrollController _scrollController = ScrollController();
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
        'title': 'Transaction',
      },
      {
        'imagePath': 'home/send',
        'title': 'Send money',
      },
      {
        'imagePath': 'home/request',
        'title': 'Request money',
      },
      {
        'imagePath': 'home/payment_link',
        'title': 'Payment Links',
      },
      {
        'imagePath': 'home/wallet',
        'title': 'Wallet',
      },
      {
        'imagePath': 'home/credit_card',
        'title': 'Credit card',
      },
      {
        'imagePath': 'home/utility',
        'title': 'Utility',
      },
    ];
    final List<Map<String, String>> business = [
      {
        'imagePath': 'home/product',
        'title': 'Product',
      },
      {
        'imagePath': 'home/service',
        'title': 'Services',
      },
      {
        'imagePath': 'home/invoice',
        'title': 'Invoice',
      },
      {
        'imagePath': 'home/contract',
        'title': 'Contract',
      },
    ];
    final List<Map<String, String>> socials = [
      {
        'imagePath': 'home/chat_social',
        'title': 'Chat',
      },
      {
        'imagePath': 'home/inbox_social',
        'title': 'Inbox',
      },
      {
        'imagePath': 'home/yarn',
        'title': 'Yarn',
      },
      {
        'imagePath': 'home/moment',
        'title': 'Moment',
      },
      {
        'imagePath': 'home/blog',
        'title': 'Blog',
      },
      {
        'imagePath': 'home/channel',
        'title': 'Channel',
      },
    ];
    final List<Map<String, String>> lifestyle = [
      {
        'imagePath': 'home/order',
        'title': 'Order',
      },
      {
        'imagePath': 'home/super_store',
        'title': 'Super store',
      },
      {
        'imagePath': 'home/service',
        'title': 'Services Hub',
      },
    ];
    final List<Map<String, String>> create = [
      {
        'imagePath': 'home/yarn',
        'title': 'Yarn',
      },
      {
        'imagePath': 'home/moment',
        'title': 'Moment',
      },
      {
        'imagePath': 'home/product',
        'title': 'Product',
      },
      {
        'imagePath': 'home/service',
        'title': 'Services',
      },
      {
        'imagePath': 'home/inbox',
        'title': 'Inbox',
      },
      {
        'imagePath': 'home/blog',
        'title': 'Blog',
      },
      {
        'imagePath': 'home/contract',
        'title': 'Contract',
      },
      {
        'imagePath': 'home/invoice',
        'title': 'Invoice',
      },
      {
        'imagePath': 'home/channel',
        'title': 'Channel',
      },
      {
        'imagePath': 'home/group',
        'title': 'Group',
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
        print('Tapped on an unknown shortcut');
    }
  }

  _isRefreshing() {
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
          SizedBox(height: 6),
          // searchBox(),
          // SizedBox(height: 16),
          Expanded(
            child: _displayShortcutCard(filteredList.isNotEmpty ? filteredList : selectedList),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: CircularLoadingIndicator(),
        ),
      ),
    );
  }

  Widget searchBox() {
    try {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
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
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              prefix: Padding(
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
      child: Container(
        // height: 250.0,
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
                    return Expanded(
                      child: SizedBox(),
                    );
                  } else {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: GestureDetector(
                          onTap: () {
                            if (appBarTitle == 'Create') {
                              onClickShortcutCreate(shortcut['title']!);
                            } else {
                              onClickShortcut(shortcut['title']!);
                            }
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: shortcutView(
                              shortcut['imagePath']!,
                              shortcut['title']!,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget shortcutView(String imagePath, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: greyBorderColor),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: [
              SvgPicture.asset(
                imagePath.toSVG(),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: black,
                ),
              ),
              if (userBloc.user.type!.toLowerCase() == 'user' &&
                      title == 'Product' ||
                  userBloc.user.type!.toLowerCase() == 'user' && title == 'Services') ...[
                const SizedBox(width: 10),
                SvgPicture.asset(
                  'home/padlock'.toSVG(),
                  color: darkGreyYarn,
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  void onClickShortcut(String title) {
    switch (title) {
      case 'Transaction':
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
      case 'Send money':
        Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
            arguments: <String, bool>{'isFromProfile': true});
        break;
      case 'Request money':
        Navigator.pushNamed(context, Routes.ACCOUNTS);
        break;
      case 'Payment Links':
        BottomSheetPassCode(
            context: context,
            isValidCallback: () {
              NavigationUtil.push(context, screen: PaymentLink());
            },
            cancelCallBack: () {
              Navigator.pop(context);
            });
        break;
      case 'Wallet':
        Navigator.of(context).pushNamed(Routes.ADD_MONEY_TO_SLYDO_ONE);
        break;
      case 'Credit card':
        if (appConfigurationModel?.enableAddUserCreditCard == true) {
          Navigator.of(context).pushNamed(Routes.CREDIT_CARD_OPTION_SELECTION);
        } else {
          showToast(message: 'Coming soon.');
        }
        break;
      case 'Utility':
        if (appConfigurationModel?.enableUtility == true) {
          Navigator.pushNamed(context, Routes.UTILITY_DASHBOARD);
        } else {
          showToast(message: 'Coming soon.');
        }
        break;
      case 'Product':

        NavigationUtil.push(context, screen: const MyProducts());
        break;
      case 'Services':
        NavigationUtil.push(context, screen: const MyServices());
        break;
      case 'Invoice':
        if (appConfigurationModel?.enableInvoice == true) {
          Navigator.pop(context);
          Navigator.pushNamed(context, Routes.INVOICE_SCREEN);
        } else {
          showToast(message: 'Coming soon');
        }
        break;
      case 'Contract':
        if (appConfigurationModel?.enableContract == true) {
          Navigator.pop(context);
          Navigator.pushNamed(context, Routes.CONTRACT_SCREEN);
        } else {
          showToast(message: 'Coming soon');
        }
        break;
      case 'Chat':
        NavigationUtil.push(context, screen: ConnectionDashboard());
        break;
      case 'Inbox':
        Navigator.of(context).pushNamed(Routes.MESSAGE_LIST);
        break;
      case 'Yarn':
        NavigationUtil.push(context, screen: YarnDashboard());
        break;
      case 'Moment':
        NavigationUtil.push(context, screen: MomentsScreen());
        break;
      case 'Blog':
        if (appConfigurationModel?.enableSuperBlog == true) {
          NavigationUtil.push(
            context,
            screen: const SuperBlog(),
          );
        } else {
          showToast(message: 'Feature not available at the moment');
        }
        break;
      case 'Channel':
        break;
      case 'Order':
        Navigator.pushNamed(context, Routes.ORDERS_LIST);
        break;
      case 'Super store':
        NavigationUtil.push(context, screen: SuperStore());
        break;
      case 'Services Hub':
        Navigator.pushNamed(context, Routes.SUPER_HUB);
        break;
      default:
        // Handle the default case (if any)
        print('Tapped on an unknown shortcut');
    }
  }

  void onClickShortcutCreate(String title) {
    switch (title) {
      case 'Yarn':
        NavigationUtil.push(context,
            screen: AddOrEditYarn(
              askCategories: yarnDashboardBloc.yarnCategories,
              shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
              isYarn: true,
              passedCategory: '',
            ));
        break;
      case 'Moment':
        NavigationUtil.push(context, screen: CreateMediaMomentScreen());
        break;
      case 'Product':
        if (userBloc.user.type!.toLowerCase() == 'user') {
          showUpgradeDialog(context);
        } else {
          Navigator.pushNamed(context, Routes.ADD_PRODUCT);

        }

        break;
      case 'Services':
        if (userBloc.user.type!.toLowerCase() == 'user') {
          showUpgradeDialog(context);
        } else {
          Navigator.pushNamed(context, Routes.ADD_SERVICE);
        }

        break;
      case 'Inbox':
        Navigator.of(context).pushNamed(Routes.MESSAGE_LIST);
        break;

      case 'Blog':
        Navigator.of(context).pushNamed(Routes.CREATE_BLOG);
        // showToast(message: 'Coming soon');
        break;
      case 'Invoice':
        if (appConfigurationModel?.enableInvoice == true) {
          Navigator.pop(context);
          Navigator.pushNamed(context, Routes.INVOICE_SCREEN);
        } else {
          showToast(message: 'Coming soon');
        }
        break;
      case 'Contract':
        if (appConfigurationModel?.enableContract == true) {
          Navigator.pop(context);
          Navigator.pushNamed(context, Routes.CONTRACT_SCREEN);
        } else {
          showToast(message: 'Coming soon');
        }
        break;
      case 'Channel':
        // if (appConfigurationModel != null &&
        //     appConfigurationModel!.enableGroupChat == true) {
          Navigator.of(context).pushNamed(Routes.SELECT_USER_FOR_GROUP,
              arguments: {"create": "channel"});
        // }
        break;
      case 'Group':
        // if (appConfigurationModel != null &&
        //     appConfigurationModel!.enableGroupChat == true) {
          Navigator.of(context).pushNamed(Routes.SELECT_USER_FOR_GROUP,
              arguments: {"create": "group"});
        // }
        break;
      default:
        // Handle the default case (if any)
        print('Tapped on an unknown shortcut');
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
