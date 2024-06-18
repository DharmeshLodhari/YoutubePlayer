import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/item_display_service_for_discount.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class UserServicesDiscount extends StatefulWidget {
  DiscountModel item;

  UserServicesDiscount({
    required this.item,
    super.key,
  });

  @override
  State<UserServicesDiscount> createState() => _UserServicesDiscountState();
}

class _UserServicesDiscountState extends State<UserServicesDiscount> {
  int? serviceCount = 0;
  String? serviceNext = "";
  String? servicePrevious = "";
  List<Service> serviceList = [];
  bool isServiceLoading = false;
  bool noServiceInList = false;
  final ScrollController _serviceScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _serviceScaffoldKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _serviceMessengerScaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final RefreshController _serviceRefreshController =
      RefreshController(initialRefresh: false);

  late UserBloc userBloc;

  bool isSelectAll = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userBloc = Provider.of<UserBloc>(context, listen: false);
      getServiceList();
    });

    _serviceScrollController.addListener(() {
      if (_serviceScrollController.position.pixels ==
              _serviceScrollController.position.maxScrollExtent &&
          _serviceScrollController.position.pixels != 0) {
        getServiceList();
      }
    });

    super.initState();
  }

  void toggleSelectAll() {
    isSelectAll = !isSelectAll;

    for (var element in serviceList) {
      element.isChecked = isSelectAll;
    }
    if (mounted) setState(() {});
  }

  void _onServiceRefresh() async {
    if (await checkConnection(context)) {
      serviceCount = 0;
      serviceNext = "";
      servicePrevious = "";
      serviceList = [];
      debugPrint("Refresh called on services!!  ");
      getServiceList();
      _serviceRefreshController.refreshCompleted();
    } else {
      _serviceRefreshController.refreshCompleted();
    }
  }

  void getServiceList() async {
    if (!isServiceLoading) {
      if (serviceNext != null && !isServiceLoading) {
        if (mounted) {
          setState(() {
            isServiceLoading = true;
          });
        }
        final Map<String, dynamic>? result;
        if (widget.item.id != null) {
          result = await ShoppingAuthService().listOfDiscountedServices(
              serviceNext, servicePrevious, widget.item.id);
        } else {
          result = await ShoppingAuthService().listServicesByProvider(
              serviceNext, servicePrevious,
              userName: userBloc.user.userName);
        }

        if (result == null) {
          isServiceLoading = false;
          return;
        }

        final String? error = result['error'];
        if (error != null && error.toLowerCase().contains('review not found')) {
          noServiceInList = true;
          isServiceLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        serviceCount = result['count'];
        serviceNext = result['next'];
        servicePrevious = result['previous'];
        final tempList = result['results'];
        if (mounted) {
          setState(() {
            noServiceInList = false;
            isServiceLoading = false;
            serviceList.addAll(tempList);
          });
        }
      }
      if (serviceList.isEmpty) {
        if (mounted) {
          setState(() {
            noServiceInList = true;
          });
        }
      } else if (serviceNext == null && serviceList.length > 6) {
        _serviceMessengerScaffoldKey.currentState?.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _serviceMessengerScaffoldKey,
      child: Scaffold(
        backgroundColor: lightGrey,
        key: _serviceScaffoldKey,
        body: _buildBody(),
        floatingActionButton: floatingActionBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget floatingActionBar() {
    return Card(
      elevation: 50,
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 15.0),
        child: getSubmitButton(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        if (!noServiceInList && !isServiceLoading && serviceList.isNotEmpty)
          _buildSelectedData(),
        const SizedBox(
          height: 5,
        ),
        Expanded(
          child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _serviceRefreshController,
            onRefresh: _onServiceRefresh,
            child: noServiceInList
                ? NoItemInList(msg: AppLocalization.of(context)!.noResultFound)
                : _buildServiceList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedData() {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value: isSelectAll,
                onChanged: (bool? value) {
                  setState(() {
                    // isSelectAll = value ?? false;
                    toggleSelectAll();
                  });
                },
                activeColor: navyBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              Text(
                'Select All',
                style: TextStyle(
                  color: black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                ),
              )
            ],
          ),
          Text(
            "${serviceList.where((e) => e.isChecked == true).toList().length} products selected",
            style: TextStyle(
              color: deepPink,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
            ),
          ),
        ],
      ),
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        final List<Service> selectedServices =
            serviceList.where((e) => e.isChecked).toList();

        final Map<String, dynamic> items = {
          "services": selectedServices,
          "ids": selectedServices.map((e) => e.id).toList(),
          "isAllServiceSelected": isSelectAll
        };
        Navigator.pop(context, items);
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Save",
    );
  }

  Widget _buildServiceList() {
    return isServiceLoading && serviceList.isEmpty
        ? Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: greyBorderColor,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
              itemCount: 5,
              itemBuilder: (context, index) {
                return CustomBoxShadow(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: CustomBoxShadow(
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: EdgeInsets.zero,
                        shadowColor: boxShadowTwo,
                        color: lightGrey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 10,
                                        width: 50,
                                        color: Colors.blueGrey,
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        height: 8,
                                        width: 50,
                                        color: Colors.blueGrey,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 10,
                                  width: 50,
                                  color: Colors.blueGrey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _serviceScrollController,
            itemCount: serviceList.length + 1,
            itemBuilder: (context, index) {
              if (index == serviceList.length) {
                return buildJumpingLoadingIndicator(
                    isLoading: isServiceLoading);
              } else {
                return DisplayServiceForDiscount(
                  service: serviceList[index],
                  onChange: (bool value) {
                    serviceList[index].isChecked = value;
                    if (mounted) setState(() {});
                  },
                  isSelected: serviceList[index].isChecked,
                );
              }
            },
          );
  }
}
