import 'dart:io';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/VirtualAccount.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/tiles/yarn_list_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_detail_screen.dart';
import 'package:Slydo/screens/scan_qr_code.dart';
import 'package:Slydo/services/app_tutorial_controller.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/slydo_app_icon_new_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shimmer/shimmer.dart';
import '../data/currency.dart';
import '../data/database_helper.dart';
import '../locator.dart';
import '../routes/route_constants.dart';
import '../services/app_config_bloc.dart';
import '../services/auth.dart';
import '../services/secure_storage.dart';
import '../utils/country_picker/country.dart';
import '../utils/country_picker/utils.dart';
import '../utils/navigation_util.dart';
import '../widget/CustomBoxShadow.dart';
import '../widget/LoadingIndicator.dart';
import '../widget/bottom_sheet_item.dart';
import '../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../widget/dialog.dart';
import '../widget/rounded_background_icon.dart';
import '../widget/user_dashboard_item_tile.dart';
import 'moments/screens/moments_screen.dart';
import 'more_apps/messaging/button/message_nav_btn.dart';
import 'more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'more_apps/super_blog/super_blog.dart';
import 'more_apps/user_profile/models/SecureUser.dart';
import 'more_apps/user_profile/models/user.dart';
import 'more_apps/user_profile/user_auth.dart';
import 'more_apps/yarn/yarn_dashboard.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldHomeKey = GlobalKey<ScaffoldState>();
  late UserBloc userBloc;

  late MainSocketProvider socketProvider;

  bool hasMessage = true;
  late BasketBloc basketBloc;
  late AppLocalization appLocalization;
  AppConfigurationModel? appConfigurationModel;
  int accountBalance = 0;
  int actualAccountBalance = 0;
  bool isBalanceHidden = true;
  late BankAccountBloc bankAccountBloc;
  bool isLoading = false;
  final _auth = AuthService();
  bool storeLocked = true;
  late DashboardBloc dashboardBloc;
  VirtualAccount? virtualAccount;
  String accountNumber = "";
  String bankName = "";
  String accountName = "";
  bool isAccountExist = false;
  String? nextContactMoments = "";
  String? nextExploreMoments = "";
  String? previousExploreMoments = "";
  int? countExploreMoments = 0;
  bool isFirstTimeExplore = true;
  bool isExploreMomentsLoading = false;
  List<ExploreMomentsModel> exploreMomentsList = [];
  List<MomentsModel> momentsList = [];
  ScrollController _myConnectionsScrollController = ScrollController();

  List<Yarn> yarnTopicList = [];
  late YarnDashboardBloc yarnDashboardBloc;
  String? next = "", previous = "";
  int count = 0;
  bool noList = false;

  @override
  void initState() {
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;

    getYarnList(categoryId: null);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences _sharedPreferences;

      _sharedPreferences = await SharedPreferences.getInstance();
      bool isAppTutorialDone = false;
      try {
        isAppTutorialDone =
            _sharedPreferences.getBool('isAppTutorialDone') ?? false;
      } catch (error) {
        isAppTutorialDone = false;
      }

      if (!isAppTutorialDone) {
        bool result =
            await _sharedPreferences.setBool("isAppTutorialDone", true);
        debugPrint("result:- $result");
        await Future.delayed(const Duration(milliseconds: 1500)).then((value) {
          AppTutorialController().showTutorial(context);
        });
      }
    });
    getSlydoAccount();
    getAccountBalance();
    getExploreMoments();

    super.initState();
  }

  void getYarnList(
      {String type = "topic", bool isType = true, String? categoryId}) async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        String latestTrending = 'latest';

        Map<String, dynamic>? result = await YarnAuth().getAllYarn(
            next, previous ?? '',
            type: type,
            isType: isType,
            categoryId: categoryId,
            latestTrending: latestTrending,
            pageSize: 2);

        if (result == null) {
          noList = true;

          isLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }


        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];

        if (tempList.isNotEmpty) {
          noList = false;
          isLoading = false;

          List<Yarn> createYarnTopicList =
              List.from(yarnDashboardBloc.createYarnTopicList);
          List<Yarn> deleteYarnTopicList =
              List.from(yarnDashboardBloc.deleteYarnTopicList);
          List<Yarn> reYarnTopicList =
              List.from(yarnDashboardBloc.reYarnTopicList);

          /// Get the common CreateYarnTopicList objects in both lists
          List<Yarn> commonCreateYarnTopicList = tempList
              .where((o1) => createYarnTopicList.any((o2) => o2.id == o1.id))
              .toList();

          /// Remove the common reYarnTopicList objects from the main list
          yarnDashboardBloc.createYarnTopicList.removeWhere(
              (o1) => commonCreateYarnTopicList.any((o2) => o2.id == o1.id));

          /// Get the common reYarnTopicList objects in both lists
          List<Yarn> commonReYarnTopicList = tempList
              .where((o1) => reYarnTopicList.any((o2) => o2.id == o1.id))
              .toList();

          /// Remove the common reYarnTopicList objects from the main list
          yarnDashboardBloc.reYarnTopicList.removeWhere(
              (o1) => commonReYarnTopicList.any((o2) => o2.id == o1.id));

          if (yarnDashboardBloc.createYarnTopicList.isNotEmpty) {
            ///add createYarnTopicList to tempList if any

            yarnDashboardBloc.createYarnTopicList.forEach((item) {
              tempList.insert(0, item);
            });
          }

          if (yarnDashboardBloc.reYarnTopicList.isNotEmpty) {
            ///add reYarnTopicList to tempList if any

            yarnDashboardBloc.reYarnTopicList.forEach((item) {
              tempList.insert(0, item);
            });
          }

          if (deleteYarnTopicList.isNotEmpty) {
            for (Yarn obj1 in tempList) {
              bool found = false;
              for (Yarn obj2 in deleteYarnTopicList) {
                if (obj1.id == obj2.id) {
                  found = true;
                  break;
                }
              }

              if (!found) {
                yarnTopicList.add(obj1);
                // debugPrint('Check category delete batch :::: ${obj1.id}');
                if (mounted) setState(() {});
              }
            }
          } else if (deleteYarnTopicList.isEmpty) {
            yarnTopicList.addAll(tempList);
          }

          if (mounted) setState(() {});
        }
      }
    }
    if (yarnTopicList.isEmpty) {
      if (mounted) {
        setState(() {
          noList = true;
        });
      }
    } else if (next == null && yarnTopicList.length > 6) {
      // _askCategoriesScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
      //   content:
      //   Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
      //   duration: Duration(milliseconds: 500),
      // ));
    }
  }

  getExploreMoments() async {
    if (!isExploreMomentsLoading) {
      if (nextExploreMoments != null && !isExploreMomentsLoading) {
        if (mounted) {
          setState(() {
            isExploreMomentsLoading = true;
          });
        }
        Map<String, dynamic>? result = await MomentsService().getExploreMoments(
          nextExploreMoments,
          previousExploreMoments,
        );
        if (result == null) {
          isExploreMomentsLoading = false;
          return;
        }
        nextExploreMoments = result['next'];
        countExploreMoments = result['count'];
        previousExploreMoments = result['previous'];
        var tempList = result['results'];

        isExploreMomentsLoading = false;

        if (tempList != null && tempList is List && tempList.isNotEmpty) {
          for (ExploreMomentsModel e in tempList) {
            momentsList = e.moments!;
          }
        }

        debugPrint('EXPLORE MOM :: $exploreMomentsList');
        if (mounted) setState(() {});

        if (isFirstTimeExplore &&
            nextExploreMoments != null &&
            nextExploreMoments != "") {
          isFirstTimeExplore = false;
          getExploreMoments();
        }
      }
    }
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

    if (virtualAccount != null) {
      isAccountExist = true;
      if (isFromServer) {
        await DatabaseHelper().saveVirtualAccount(virtualAccount!);
      }
    }

    accountNumber = virtualAccount!.accountNumber!;
    bankName = virtualAccount!.financialInstitution!.name!;
    accountName = virtualAccount!.accountName!;

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);
    appLocalization = AppLocalization.of(context)!;
    socketProvider = Provider.of<MainSocketProvider>(context);
    dashboardBloc = Provider.of<DashboardBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);

    if (userBloc.user.type != "User") {
      storeLocked = false;
    }

    return Scaffold(
      key: _scaffoldHomeKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height),
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _foregroundScreen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foregroundScreen() {
    final List<Map<String, String>> shortcutExtraBusiness = [
      {
        'imagePath': 'home/small_payment',
        'title': appLocalization.payment,
        'subTitle': appLocalization.paymentSubTitle,
        'color': '#9B51E0',
      },
      {
        'imagePath': 'home/small_business',
        'title': appLocalization.business,
        'subTitle': appLocalization.businessSubTitle,
        'color': '#46CE7C',
      },
      {
        'imagePath': 'home/small_social',
        'title': appLocalization.social,
        'subTitle': appLocalization.socialSubTitle,
        'color': '#FFA500',
      },
      {
        'imagePath': 'home/small_lifestyle',
        'title': appLocalization.lifestyle,
        'subTitle': appLocalization.lifestyleSubTitle,
        'color': '#F07097',
      },
    ];

    return Container(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: 10),
          Container(
              padding: const EdgeInsets.only(left: 8.0), child: _appBar()),
          const SizedBox(
            height: 15,
          ),
          accountBalanceCard(),
          const SizedBox(
            height: 25,
          ),
          Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              appLocalization.quickActions,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: HexColor("#151515")),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // Container(
          //     padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          //     child: _displayPaymentButtons()),
          Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: _displayShortcutButtons()),
          Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: _displayShortcutExtraCard(shortcutExtraBusiness)),
          const SizedBox(
            height: 15,
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () =>         NavigationUtil.push(context, screen: MomentsScreen()),
                  child: sectionHeader("Share your moment", "View Moment",
                      ),
                ),
                SizedBox(height: 24),
                (nextContactMoments == '' && isExploreMomentsLoading)
                    ? Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: greyBorderColor,
                        child: SizedBox(
                          height: 180,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 120,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 180,
                        child: ListView.builder(
                          shrinkWrap: true,
                          controller: _myConnectionsScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          itemCount: momentsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == momentsList.length) {
                              return Container();
                              // buildIndicator(
                              //     isLoading: isContactMomentsLoading);
                            } else {
                              return ContactMomentsCard(
                                index: index,
                                nextPageUrl: nextContactMoments,
                                userMomentModel: momentsList[index],
                                listOfConnectionsNames:
                                    momentsList.map((e) => e.owner!).toList(),
                              );
                            }
                          },
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(height: 25),
          InkWell(
            onTap: () {
              showSnackbar(context, message: "Coming soon");
            },
            child: Container(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.only(right: 16),
                    height: 150,
                    decoration: BoxDecoration(
                        color: deepBlue,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Become a slydo dispatcher",
                          style: TextStyle(
                              color: white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Inter'),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: 194,
                          child: Text(
                            "Help slydo merchant deliver their products easier.",
                            style: TextStyle(
                                color: white,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.2,
                                fontFamily: 'Inter'),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        SizedBox(height: 12),
                        CurvedButton(
                            textColor: Colors.white,
                            fontSize: 10,
                            width: 100,
                            text: "Register Now",
                            borderRadius: 10,
                            backgroundColor: black,
                            height: 20,
                            onPressed: () async {
                              // FocusScope.of(context).unfocus();
                              // deleteProduct();
                            })
                      ],
                    ),
                  ),
                  Positioned(
                    top: 25,
                    left: 12,
                    child: Image.asset(
                      "assets/images/bike_home.png",
                      height: 131,
                      width: 141,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 32),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              children: [
                GestureDetector(
                    onTap: () =>
                        NavigationUtil.push(context, screen: YarnDashboard()),
                    child: sectionHeader("Join the conversation", "View Yarn")),
                SizedBox(height: 24),
                _buildListView()
              ],
            ),
          ),

          const SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget _displayShortcutButtons() {
    final List<Map<String, String>> shortcuts = [
      {
        'imagePath': 'home/transaction',
        'title': 'Transaction',
      },
      {
        'imagePath': 'home/send',
        'title': 'Send',
      },
      {
        'imagePath': 'home/request',
        'title': 'Request',
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
        'imagePath': 'home/service',
        'title': 'Services',
      },
      {
        'imagePath': 'home/blog',
        'title': 'Blog',
      },
    ];

    return Container(
      height: 100.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: <Widget>[
          for (final shortcut in shortcuts)
            Padding(
              padding: const EdgeInsets.all(10.0), // Add padding between items
              child: GestureDetector(
                  // key: showTutorial(shortcut['title']),
                  onTap: () {
                    onClickShortcut(shortcut['title']);
                  },
                  child:
                      shortcutView(shortcut['imagePath']!, shortcut['title']!)),
            ),
        ],
      ),
    );
  }

  Widget shortcutView(String imagePath, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          imagePath.toSVG(),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, fontFamily: "Inter"),
        ),
      ],
    );
  }

  void onClickShortcut(String? shortcut) {
    switch (shortcut) {
      case 'Send':
        hideBalance();
        Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
            arguments: <String, bool>{'isFromProfile': true});
        break;
      case 'Transaction':
        hideBalance();
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
      case 'Request':
        hideBalance();
        Navigator.pushNamed(context, Routes.ACCOUNTS);
        break;
      case 'Yarn':
        hideBalance();
        NavigationUtil.push(context, screen: YarnDashboard());
        break;
      case 'Moment':
        hideBalance();
        NavigationUtil.push(context, screen: MomentsScreen());
        break;
      case 'Services':
        hideBalance();
        Navigator.pushNamed(context, Routes.SUPER_HUB);
        break;
      case 'Blog':
        hideBalance();
        if (appConfigurationModel?.enableSuperBlog == true) {
          NavigationUtil.push(
            context,
            screen: const SuperBlog(),
          );
        } else {
          showToast(message: 'Feature not available at the moment');
        }
        break;
      default:
        // Handle the default case (if any)
        print('Tapped on an unknown shortcut');
    }
  }

  Widget _displayShortcutExtraCard(List<Map<String, String>> shortcuts) {
    final longestSubTitle = shortcuts
        .map((shortcut) => shortcut['subTitle'])
        .reduce((a, b) => a!.length > b!.length ? a : b);

    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate the dynamic height
    final dynamicHeight =
        calculateDynamicHeight(longestSubTitle!, screenHeight);

    return Container(
      child: Column(
        // padding: EdgeInsets.zero,
        children: List.generate(
          ((shortcuts.length + 1) / 2).ceil(), // Adjusted the generation logic
          (index) {
            final startIndex = index * 2;
            final endIndex = startIndex + 2;
            final pairShortcuts = shortcuts.sublist(
              startIndex,
              endIndex.clamp(
                  0, shortcuts.length), // Use clamp to avoid out-of-bounds
            );

            // If the pairShortcuts list has fewer than 2 items, add empty placeholders
            while (pairShortcuts.length < 2) {
              pairShortcuts.add({});
            }

            return Row(
              children: pairShortcuts.map((shortcut) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: shortcut.isEmpty
                        ? Container() // Empty view placeholder
                        : GestureDetector(
                            onTap: () {
                              onClickShortcutExtra(shortcut['title']!);
                            },
                            child: shortcutViewExtra(
                                shortcut['imagePath']!,
                                shortcut['title']!,
                                shortcut['subTitle']!,
                                shortcut['color']!,
                                dynamicHeight),
                          ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      physics: ScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 16),
      // scrollDirection: Axis.horizontal,
      // controller: _scrollController,
      itemCount: yarnTopicList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == yarnTopicList.length) {
          return Container();
          // _buildLoadingIndicator();
        }

        return InkWell(
          onTap: () async {
            if (yarnTopicList[index].enableCommenting ?? false) {
              await NavigationUtil.push(
                context,
                screen: YarnDetailScreen(
                  yarn: yarnTopicList[index],
                ),
              );
            }
            if (mounted) setState(() {});
          },
          child: YarnTile(
            yarn: yarnTopicList[index],
          ),
        );
      },
    );
  }

  Widget sectionHeader(title, more) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
              color: black,
              fontSize: 15,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
            )),
        InkWell(
          // onTap: () {
          //    NavigationUtil.push(context, screen: widgetRoute);
          // },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                more,
                style: TextStyle(
                  color: navyBlue,
                  fontSize: 14,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget shortcutViewExtra(String imagePath, String title, String subTitle,
      String color, double dynamicHeight) {
    double opacity = 0.8;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      height: 80.0 + dynamicHeight,
      // height: 110.0,
      decoration: BoxDecoration(
        color: HexColor(color).withOpacity(opacity),
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
                    fontSize: 16,
                    color: white,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Inter"),
              ),
              if (userBloc.user.type!.toLowerCase() == 'user' &&
                  title == 'Business') ...[
                const SizedBox(width: 5),
                SvgPicture.asset(
                  'home/padlock'.toSVG(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subTitle,
            style: TextStyle(fontSize: 14, color: white, fontFamily: "Inter"),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  double calculateDynamicHeight(String longestSubTitle, double screenWidth) {
    // Define a maximum font size to avoid overflow
    const double maxFontSize = 14.0;

    // Calculate the dynamic height based on the longest subtitle
    final textSpan = TextSpan(
      text: longestSubTitle,
      style: TextStyle(fontSize: maxFontSize),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: screenWidth);

    // You can add some padding to the height if needed
    return textPainter.height + 20; // 20 for padding
  }

  void onClickShortcutExtra(String shortcut) {
    switch (shortcut) {
      case 'Payment':
        hideBalance();
        Navigator.of(context).pushNamed(Routes.HOME_QUICK_VIEW,
            arguments: {"view": appLocalization.payment});
        break;
      case 'Business':
        if (userBloc.user.type!.toLowerCase() != 'user') {
          hideBalance();
          Navigator.of(context).pushNamed(Routes.HOME_QUICK_VIEW,
              arguments: {"view": appLocalization.business});
        } else {
          showUpgradeDialog(context);
        }

        break;
      case 'Socials':
        hideBalance();
        Navigator.of(context).pushNamed(Routes.HOME_QUICK_VIEW,
            arguments: {"view": appLocalization.social});
        break;
      case 'Lifestyles':
        hideBalance();
        Navigator.of(context).pushNamed(Routes.HOME_QUICK_VIEW,
            arguments: {"view": appLocalization.lifestyle});
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

  Widget _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: false,
      leading: InkWell(
        onTap: () {
          profileAndroidSheet();
        },
        child: userImageUserInitialsPic(
            userBloc.user.avatar!, userBloc.user.fullName!, 25, 48),
      ),
      title: InkWell(
        key: tutorialUserProfileDetailKey,
        onTap: () {
          Navigator.pushNamed(context, Routes.USER_PROFILE,
              arguments: {"searchedUserName": userBloc.user.userName});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              getGreetingMessage(),
              style: TextStyle(fontSize: 12, fontFamily: 'Inter', color: HexColor("#151515",)),
            ),
            userNameWithVerifiedIcon(
              name: userBloc.user.displayName()!,
              isVerified: userBloc.user.isVerified,
              verifiedIconColor: verifyGreen,
              textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: HexColor("#151515")),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        RoundedBackgroundIcon(
            backgroundColor: Colors.transparent,
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.SEARCH_MODULE,
              );
              // arguments: {"industry": {"discount": widget.discount!.id}
            },
            height: 15,
            width: 15,
            icon: SvgPicture.asset(
              "yarn/search".toSVG(),
              height: 12,
              width: 12,
            )),
        // _searchBtn(),
        // const SizedBox(width: 4.0),
        _cartBtn(),
        // const SizedBox(width: 8.0),
        // _settingBtn(),
        const SizedBox(width: 8.0),
      ],
    );
  }

  Widget _cartBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      key: tutorialShoppingCartKey,
      icon: badges.Badge(
        badgeContent: getBadgeContent(),
        position: badges.BadgePosition.topEnd(
            end: getBadgeCount().length == 1 ? -5 : 0, top: 0),
        badgeAnimation: const badges.BadgeAnimation.rotation(
          animationDuration: Duration(seconds: 1),
          colorChangeAnimationDuration: Duration(seconds: 1),
          loopAnimation: false,
          curve: Curves.fastOutSlowIn,
          colorChangeAnimationCurve: Curves.easeInCubic,
        ),
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.circle,
          badgeColor: naturalGreen,
          padding: basketBloc.items.length == 0
              ? const EdgeInsets.all(0)
              : EdgeInsets.only(
                  left: getBadgeCount().length == 1 ? 6 : 8,
                  right: 6,
                  top: 4,
                  bottom: 4),
          elevation: 0,
        ),
        child: Center(
          child: Icon(
            SlydoAppIconNew.cart,
            size: 16,
            color: HexColor("#151515"),
          ),
        ),
      ),
      onTap: () {
        // Navigator.of(context).pushNamed(Routes.SIGN_UP, arguments: {
        //   'phoneNumber': "+000000000000",
        //   'otpCode': "123456",
        //   'accountType': "Business"
        // });

        hideBalance();
        NavigationUtil.pushNamed(context, routeName: Routes.SHOPPING_CART);
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: true,
    );
  }

  Widget? getBadgeContent() {
    if (basketBloc.items.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount(),
      style: const TextStyle( fontFamily: 'Inter',
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;
    basketBloc.items.forEach((element) {
      totalItem = totalItem + int.parse(element['qty'].toString());
    });
    return totalItem > 99 ? '99+' : totalItem.toString();
  }

  Widget accountBalanceCard() {
    return CustomBoxShadow(
      child: Card(
        shadowColor: boxShadowTwo,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Container(
          width: double.infinity,
          decoration: decorateBox(color: navyBlue),
          child: Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: topPadding(),
              bottom: bottomPadding(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                balanceRow(),
                accountInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double topPadding() {
    return MediaQuery.of(context).size.height > 600 ? 4 : 2;
  }

  double bottomPadding() {
    return MediaQuery.of(context).size.height > 600 ? 6 : 4;
  }

  Widget balanceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        balanceColumn("Total Balance", accountBalance),
        balanceColumn("Book Balance", actualAccountBalance),
      ],
    );
  }

  Widget balanceColumn(String label, int balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 15.0,
        ),
        InkWell(
          onTap: () {
            if (label == 'Total Balance') {
              toggleBalanceVisibility();
            }
          },
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: white,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            if (label == 'Total Balance') ...[
              InkWell(
                  onTap: () {
                    toggleBalanceVisibility();
                  },
                  child: actualBalance(balance)),
              const SizedBox(
                width: 10.0,
              ),
              InkWell(
                onTap: () {
                  toggleBalanceVisibility();
                },
                child: Padding(
                  padding: isBalanceHidden
                      ? const EdgeInsets.only(bottom: 5.0)
                      : const EdgeInsets.only(bottom: 0.0),
                  child: Icon(
                    isBalanceHidden ? SlydoAppIcon.eye : SlydoAppIcon.eye_close,
                    color: white,
                    size: 12,
                  ),
                ),
              ),
            ] else ...[
              actualBalance(balance),
            ]
          ],
        ),
      ],
    );
  }

  Widget actualBalance(int balance) {
    return isLoading == true
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularLoadingIndicator(color: naturalGreen),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isBalanceHidden
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        worldCurrencies[userBloc.user.currency!]!,
                        style: TextStyle(
                          color: white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                         fontFamily: 'Inter',
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  isBalanceHidden
                      ? generateAsteriskMask(moneyDisplayNormalizer(balance))
                      : moneyDisplayNormalizer(balance),
                  style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          );
  }

  void toggleBalanceVisibility() {
    if (isBalanceHidden) {
      BottomSheetPassCode(
        context: context,
        isValidCallback: () {
          isLoading = true;
          getAccountBalance();
          isBalanceHidden = false;
          setState(() {});
        },
        cancelCallBack: () {
          Navigator.pop(context);
        },
      );
    } else {
      isBalanceHidden = !isBalanceHidden;
      setState(() {});
    }
  }

  Widget accountInfo() {
    if (accountNumber != "") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15.0),
          Text(
            bankName,
            style: TextStyle(
              fontSize: 14,
              color: white,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              Text(
                accountNumber,
                style: TextStyle(
                  fontSize: 14,
                  color: white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              GestureDetector(
                onTap: copyAccountDetails,
                child: SvgPicture.asset(
                  "ampersand".toSVG(),
                  width: 15,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appendStringDot(accountName, 30),
                style: TextStyle(
                  fontSize: 14,
                  color: white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              qrCodeIcon(),
            ],
          ),
        ],
      );
    } else {
      return Container(); // Placeholder for empty account info
    }
  }

  void copyAccountDetails() {
    Clipboard.setData(ClipboardData(
      text:
          "Bank name: ${virtualAccount!.financialInstitution!.name}\nAccount name: ${virtualAccount!.accountName}\nAccount number: ${virtualAccount!.accountNumber}",
    ));
    showToast(message: "Account details copied !!");
  }

  Widget qrCodeIcon() {
    return RoundedBackgroundIcon(
      key: tutorialScanQrCodeKey,
      height: 34,
      width: 34,
      icon: const Icon(
        SlydoAppIcon.qr_code,
        size: 16,
        color: Colors.white,
      ),
      onTap: () async {
        NavigationUtil.push(context,
            screen: QRCodeView(arguments: {'isRequest': false}));
        // NavigationUtil.push(context, screen: QrCodePage(arguments: {'isProfile': 'false', 'virtualAccount': virtualAccount}));
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: false,
    );
  }

  void hideBalance() {
    if (isBalanceHidden == false) {
      isBalanceHidden = true;
      if (mounted) setState(() {});
    }
  }

  Future<void> getAccountBalance() async {
    await PaymentAndBankingAuth().getAccountBalance().then((value) {
      var data = value!;
      var spendableBalance = data["spendable_balance"];
      var actualBalance = data["balance"];

      accountBalance = spendableBalance;
      actualAccountBalance = actualBalance;
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  checkUser() {
    if (userBloc.user.type.toString().toLowerCase() == 'user') {
      return Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          // first row
          Row(
            children: [
              Expanded(
                  key: tutorialOrderKey,
                  child: UserDashboardItemTile(
                    icon: SlydoAppIcon.cart,
                    title: "Orders",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.ORDERS_LIST);
                    },
                    iconColor: HexColor("#FFAB00"),
                  )),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                key: tutorialInboxKey,
                child: UserDashboardItemTile(
                  iconWidget: const MessageNavBtn(),
                  title: "Inbox",
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.MESSAGE_LIST);
                  },
                  iconColor: HexColor("#374677"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                key: tutorialBlogsKey,
                child: UserDashboardItemTile(
                  icon: SlydoAppIcon.news_moreapps,
                  title: AppLocalization.of(context)!.blogs,
                  onTap: () {
                    if (appConfigurationModel?.enableSuperBlog == true) {
                      hideBalance();
                      NavigationUtil.push(
                        context,
                        screen: const SuperBlog(),
                      );
                    } else {
                      showToast(message: 'Feature not available at the moment');
                    }
                  },
                  iconColor: HexColor("#F35B46"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UserDashboardItemTile(
                  icon: SlydoAppIcon.utility,
                  title: "Utility",
                  onTap: () {
                    if (appConfigurationModel?.enableUtility == true) {
                      hideBalance();
                      Navigator.pushNamed(context, Routes.UTILITY_DASHBOARD);
                    } else {
                      showToast(message: 'Coming soon.');
                    }
                  },
                  iconColor: HexColor("#FFAB00"),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          //second row
          Row(
            children: [
              Expanded(
                child: UserDashboardItemTile(
                  icon: SlydoAppIconNew.vector_1,
                  title: AppLocalization.of(context)!.services,
                  onTap: () {
                    // if (appConfigurationModel?.enableUtility == true) {
                    //   Navigator.pushNamed(context, Routes.SUPER_HUB);
                    // } else {
                    //   showToast(message: 'Coming soon.');
                    // }
                    hideBalance();
                    Navigator.pushNamed(context, Routes.SUPER_HUB);
                  },
                  iconColor: HexColor("#9B51E0"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Container()),
              const SizedBox(width: 12),
              Expanded(child: Container()),
              const SizedBox(width: 12),
              Expanded(child: Container()),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          // first row
          Row(
            children: [
              Expanded(
                  child: UserDashboardItemTile(
                icon: SlydoAppIcon.store,
                title: "My Store",
                isLocked: storeLocked,
                onTap: () {
                  if (!storeLocked) {
                    storeItemAndroidSheet();
                  } else {
                    showToast(
                        message:
                            'You need to upgrade to a business account to use this feature.');
                  }
                },
                iconColor: HexColor("#46CE7C"),
              )),
              const SizedBox(width: 12),
              Expanded(
                  key: tutorialOrderKey,
                  child: UserDashboardItemTile(
                    icon: SlydoAppIcon.cart,
                    title: "Orders",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.ORDERS_LIST);
                    },
                    iconColor: HexColor("#FFAB00"),
                  )),
              const SizedBox(width: 12),
              Expanded(
                key: tutorialInboxKey,
                child: UserDashboardItemTile(
                  iconWidget: const MessageNavBtn(),
                  title: "Inbox",
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.MESSAGE_LIST);
                  },
                  iconColor: HexColor("#374677"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                key: tutorialBlogsKey,
                child: UserDashboardItemTile(
                  icon: SlydoAppIcon.news_moreapps,
                  title: AppLocalization.of(context)!.blogs,
                  onTap: () {
                    if (appConfigurationModel?.enableSuperBlog == true) {
                      hideBalance();
                      NavigationUtil.push(
                        context,
                        screen: const SuperBlog(),
                      );
                    } else {
                      showToast(message: 'Feature not available at the moment');
                    }
                  },
                  iconColor: HexColor("#F35B46"),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          // second row
          Row(
            children: [
              Expanded(
                child: UserDashboardItemTile(
                  icon: Icons.business_center_rounded,
                  title: AppLocalization.of(context)!.business,
                  isLocked: storeLocked,
                  onTap: () {
                    if (!storeLocked) {
                      // Navigator.of(context).pushNamed(Routes.CONTRACTS);
                      businessAndroidSheet();
                    } else {
                      showToast(
                          message:
                              'You need to upgrade to a business account to use this feature.');
                    }
                  },
                  iconColor: HexColor("#5218E9"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UserDashboardItemTile(
                  icon: SlydoAppIconNew.vector_1,
                  title: AppLocalization.of(context)!.services,
                  onTap: () {
                    // if (appConfigurationModel?.enableUtility == true) {
                    //   Navigator.pushNamed(context, Routes.SUPER_HUB);
                    // } else {
                    //   showToast(message: 'Coming soon.');
                    // }
                    hideBalance();
                    Navigator.pushNamed(context, Routes.SUPER_HUB);
                  },
                  iconColor: HexColor("#9B51E0"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UserDashboardItemTile(
                  icon: SlydoAppIcon.utility,
                  title: "Utility",
                  onTap: () {
                    if (appConfigurationModel?.enableUtility == true) {
                      hideBalance();
                      Navigator.pushNamed(context, Routes.UTILITY_DASHBOARD);
                    } else {
                      showToast(message: 'Coming soon.');
                    }
                  },
                  iconColor: HexColor("#FFAB00"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Container()),
              const SizedBox(width: 12),
            ],
          ),
        ],
      );
    }
  }

  void storeItemAndroidSheet() {
    hideBalance();
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    bottomSheetItem(
                      title: "Add product",
                      iconData: SlydoAppIcon.product,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.ADD_PRODUCT);
                      },
                    ),
                    bottomSheetItem(
                      title: "Add service",
                      iconData: SlydoAppIcon.note_2,
                      isLast: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.ADD_SERVICE);
                      },
                    ),
                  ],
                ),
              ));
        });
  }

  void businessAndroidSheet() {
    hideBalance();
    androidBottomSheet(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            bottomSheetItem(
                title: 'Contract',
                iconData: Icons.description_rounded,
                onTap: () {
                  if (appConfigurationModel?.enableContract == true) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.CONTRACT_SCREEN);
                  } else {
                    showToast(message: 'Coming soon');
                  }
                }),
            bottomSheetItem(
                title: "Invoice",
                iconData: Icons.receipt_outlined,
                onTap: () {
                  if (appConfigurationModel?.enableInvoice == true) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.INVOICE_SCREEN);
                  } else {
                    showToast(message: 'Coming soon');
                  }
                }),
          ],
        ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) setState(() {});
  }

  String getGreetingMessage() {
    TimeOfDay currentTime = TimeOfDay.now();

    if (currentTime.hour >= 6 &&
        (currentTime.hour <= 11 && currentTime.minute <= 59)) {
      return "${appLocalization.goodMorning},";
    } else if (currentTime.hour >= 12 &&
        (currentTime.hour <= 16 && currentTime.minute <= 59)) {
      return "${appLocalization.goodAfternoon},";
    } else if (currentTime.hour >= 17 &&
        (currentTime.hour <= 19 && currentTime.minute <= 59)) {
      return "${appLocalization.goodEvening},";
    } else {
      return "${appLocalization.goodEvening},";
    }
  }

  void profileAndroidSheet() {
    hideBalance();
    androidBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          bottomSheetItem(
            title: AppLocalization.of(context)!.myProfile,
            iconData: SlydoAppIcon.user,
            onTap: () async {
              await UserAuth()
                  .fetchCustomerProfile(userBloc.user.userName)
                  .then((user) {
                if (mounted) {
                  Navigator.pop(myGlobals.navigationKey.currentContext!);
                  Navigator.pushNamed(myGlobals.navigationKey.currentContext!,
                      Routes.USER_PROFILE,
                      arguments: {"searchedUserName": user.userName});
                }
              });
            },
          ),
          bottomSheetItem(
            title: AppLocalization.of(context)!.updateMyAvatar,
            iconData: SlydoAppIcon.image,
            onTap: () {
              Navigator.pop(context);
              pickImage();
            },
          ),
          bottomSheetItem(
            title: "Billing address",
            iconData: SlydoAppIcon.location,
            isLast: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                Routes.USER_ADDRESS,
              );
            },
          ),
        ],
      ),
    );
  }

  void pickImage() async {
    String? croppedImage = await getCroppedImage(context);

    if (croppedImage != null) {
      try {
        isLoading = true;
        if (mounted) setState(() {});

        User? _user = await DatabaseHelper().getUser();

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        String countryFromPref = sharedPreferences.getString('country') ?? "NG";

        Country country =
            CountryPickerUtils.getCountryByIsoCode(countryFromPref);

        SecureUser secureUser = await SecureStorage().getUser();
        String phoneNumber = secureUser.phoneNumber ?? "";
        String password = secureUser.password ?? "";

        if (phoneNumber != "") {
          phoneNumber = "+" + country.phoneCode! + phoneNumber;
        }

        if (phoneNumber == "" || password == "") {
          phoneNumber = _user?.phoneNumber ?? "";
          password = _user?.password ?? "";
        }

        if (phoneNumber == "" || password == "") {
          isLoading = false;
          if (mounted) setState(() {});
          return;
        }

        // Upload Image new image
        await UserAuth().updateUserAvatar(File(croppedImage));

        // Get new updated user data and set new user data to userBloc.
        await _auth.authenticate(phoneNumber, password).then((value) {
          userBloc.user = value;
          isLoading = false;
          if (mounted) setState(() {});
          dashboardBloc.index = 0;
        });
      } catch (err) {
        isLoading = false;
        if (mounted) setState(() {});
        // showToast(message: err.toString());
        debugPrint("Cannot Update Avatar : " + err.toString());
      }
    }
  }

  String generateAsteriskMask(String amount) {
    // Determine the length of the amount
    int amountLength = amount.length;

    // Generate a string of asterisks of the same length as the amount
    String asteriskMask = '*' * amountLength;

    // Trim the trailing space and return the asterisk mask
    return asteriskMask.trim();
  }

  showTutorial(String? shortcut) {
    switch (shortcut) {
      case 'Send':
        tutorialSendPaymentKey;
        break;
      case 'Transaction':
        tutorialTransactionKey;
        break;
      case 'Request':
        tutorialRequestPaymentKey;
        break;
      case 'Yarn':
        tutorialYarnKey;
        break;
      case 'Moment':
        break;
      case 'Services':
        break;
      case 'Blog':
        break;
      default:
        // Handle the default case (if any)
        print('Tapped on an unknown shortcut');
    }
  }
}
