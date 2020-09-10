import 'package:Slydo/data/currency.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class UserServiceList extends StatefulWidget {
  CustomerProfile user;
  bool isOwner;

  UserServiceList({@required this.user, this.isOwner = false});

  @override
  _UserServiceListState createState() => _UserServiceListState();
}

class _UserServiceListState extends State<UserServiceList> {
  final _auth = AuthService();
  final GlobalKey<ScaffoldState> _serviceScaffoldKey =
      new GlobalKey<ScaffoldState>();

  // this variable responsible for service pagination
  int serviceCount = 0;
  String serviceNext = "";
  String servicePrevious = "";
  List<Service> serviceList = [];
  ScrollController _serviceScrollController = new ScrollController();
  RefreshController _servicesRefreshController =
      RefreshController(initialRefresh: false);
  bool isServiceLoading = false;
  bool noServiceInList = false;

  void _onServiceRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        serviceCount = 0;
        serviceNext = "";
        servicePrevious = "";
        serviceList = [];
        debugPrint("Refresh called on Service!!  ");
        getServiceList();
        _servicesRefreshController.refreshCompleted();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _servicesRefreshController.refreshCompleted();
      }
    });
  }

  @override
  void initState() {
    this.getServiceList();
    _serviceScrollController.addListener(() {
      if (_serviceScrollController.position.pixels ==
              _serviceScrollController.position.maxScrollExtent &&
          _serviceScrollController.position.pixels != 0) {
        getServiceList();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _serviceScaffoldKey,
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _servicesRefreshController,
            onRefresh: _onServiceRefresh,
            child: _buildServiceList()),
      ),
    );
  }

  Widget _buildServiceList() {
    return noServiceInList
        ? NoItemInList(
            msg: AppLocalization.of(context).noServices,
          )
        : ListView.builder(
            controller: _serviceScrollController,
            itemCount: serviceList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == serviceList.length) {
                return _buildServiceIndicator();
              } else {
                return serviceTileExpanded(index);
              }
            });
  }

  Widget _buildServiceIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isServiceLoading ? 1.0 : 00,
            child: isServiceLoading
                ? CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
                  )
                : Container()),
      ),
    );
  }

  void getServiceList() async {
    if (!isServiceLoading) {
      if (serviceNext != null && !isServiceLoading) {
        if (mounted) {
          setState(() {
            isServiceLoading = true;
          });
        }
        Map<String, dynamic> result = await _auth.listServicesByProvider(
            serviceNext, servicePrevious,
            userId: widget.user.userName);
        serviceCount = result['count'];
        serviceNext = result['next'];
        servicePrevious = result['previous'];
        var tempList = result['results'];
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
        _serviceScaffoldKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget serviceTileExpanded(int index) {
    return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height / 2.75,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(children: <Widget>[
                    InkWell(
                      child: CachedNetworkImage(
                        width: double.infinity,
                        imageUrl: serviceList[index].serverImages[0],
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/service-detail',
                            arguments: {"service": serviceList[index]});
                      },
                    ),
                    widget.isOwner
                        ? Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  '/edit-service',
                                  arguments: {
                                    "serviceId":
                                        serviceList[index].id.toString(),
                                  },
                                );
                              },
                            ),
                          )
                        : Container()
                  ]),
                ),
                ListTile(
                    dense: true,
                    title: Text(
                      serviceList[index].name,
                      maxLines: 1,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      serviceList[index].shortDescription,
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: worldCurrencies[serviceList[index].currency],
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        TextSpan(text: " "),
                        TextSpan(
                            text: serviceList[index].price.toString(),
                            style: TextStyle(color: Colors.black))
                      ]),
                    )),
              ],
            ),
          ),
        ));
  }
}
