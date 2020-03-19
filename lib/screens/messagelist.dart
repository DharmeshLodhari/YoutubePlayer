import 'package:Slydo/models/message.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/message.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

class MessageList extends StatefulWidget {
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _auth = AuthService();
  SlidableController slidableController;
  int count = 0;
  String next = "";
  String previous = "";
  List messageList = [];
  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  String filterValue = "All";

  @protected
  void initState() {
    this.getList();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getList();
      }
    });
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    super.initState();
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        messageList = [];
        getList();
        _refreshController.refreshCompleted();
        print("Refresh Controller called !!!");
      } else {
        Toast.show("Internet Connection is not available", context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/dashboard');
          return false;
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: lightBlue(),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: darkBlue(),
            title: Text('Messages'),
            actions: <Widget>[_threeItemPopup()],
          ),
          body: SmartRefresher(
              enablePullDown: true,
              header: WaterDropHeader(
                complete: Container(),
                waterDropColor: darkBlue(),
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildMessageList()),
          floatingActionButton: FloatingActionButton(
            backgroundColor: darkBlue(),
            child: Icon(Icons.message),
            onPressed: () {
              Navigator.of(context).pushNamed("/compose_message");
            },
          ),
        ));
  }

  Widget _threeItemPopup() => PopupMenuButton(
        padding: EdgeInsets.all(0),
        captureInheritedThemes: true,
        itemBuilder: (context) {
          var list = List<PopupMenuEntry<Object>>();
          list.add(
            PopupMenuItem(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Filter"),
                  Icon(
                    Icons.sort,
                    color: Colors.black,
                  )
                ],
              ),
              value: 1,
            ),
          );
          list.add(
            PopupMenuDivider(
              height: 10,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "All",
                style: TextStyle(color: Colors.black),
              ),
              value: "All",
              checked: filterValue == "All" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Archived",
                style: TextStyle(color: Colors.black),
              ),
              value: "Archived",
              checked: filterValue == "Archived" ? true : false,
            ),
          );

          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Sent",
                style: TextStyle(color: Colors.black),
              ),
              value: "Sent",
              checked: filterValue == "Sent" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                "Starred",
                style: TextStyle(color: Colors.black),
              ),
              value: "Starred",
              checked: filterValue == "Starred" ? true : false,
            ),
          );
          return list;
        },
        onSelected: (Object object) {
          setState(() {
            if (object != 1) {
              filterValue = object;
              _onRefresh();
            }
          });
        },
      );

  Widget _buildMessageList() {
    return noItemInList
        ? NoItemInList(
            msg: "No Messages",
          )
        : ListView.builder(
            //+1 for progressbar
            itemCount: messageList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == messageList.length) {
                return _buildIndicator();
              } else {
                return _getSlidableWithLists(
                    context, messageList[index], index);
              }
            },
            controller: _scrollController,
          );
  }

  Widget _buildIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isLoading ? 1.0 : 00,
            child: isLoading
                ? new CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )
                : Container()),
      ),
    );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        setState(() {
          isLoading = true;
        });
//        Map<String, dynamic> result =
//            await _auth.listPaymentRequests(next, previous);
//        count = result['count'];
//        next = result['next'];
//        previous = result['previous'];
//        var tempList = result['results'];
//        setState(() {
//          isLoading = false;
//          messageList.addAll(tempList);
//        });

        List<PartialMessage> result = _auth.listMessages(filter: filterValue);

        setState(() {
          isLoading = false;
          messageList.addAll(result);
        });
      }
      if (messageList.isEmpty) {
        setState(() {
          noItemInList = true;
        });
      } else if (next == null && messageList.length > 6) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Your have reached the bottom of the list"),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Animation<double> _rotationAnimation;
  Color _fabColor = Colors.blue;

  //TODO:starred, archived, delete, markedAsread

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.green : Colors.blue;
    });
  }

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listActionSlideActions(
      PartialMessage partialMessage, int index) {
    return [displayArchviedUnArchivedButton(partialMessage, index)];
  }

  Widget displayArchviedUnArchivedButton(
      PartialMessage partialMessage, int index) {
    return Container(
        height: double.infinity,
        color: Colors.green,
        child: IconButton(
          icon: partialMessage.isArchived
              ? Icon(
                  Icons.unarchive,
                  color: Colors.white,
                )
              : Icon(
                  Icons.archive,
                  color: Colors.white,
                ),
          onPressed: () {
            markArchivedUnArchivedMessage(partialMessage, index);
            slidableController.activeState.close();
          },
        ));
  }

  void markArchivedUnArchivedMessage(PartialMessage partialMessage, int index) {
    setState(() {
      partialMessage.isArchived = partialMessage.isArchived ? false : true;
    });
  }

  List<Widget> listSecondaryActions(PartialMessage partialMessage, int index) {
    return [displayDeleteButton(partialMessage, index)];
  }

  Widget displayDeleteButton(PartialMessage partialMessage, int index) {
    return Container(
        height: double.infinity,
        color: Colors.red,
        child: IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.white,
          ),
          onPressed: () {
            deleteMessage(partialMessage, index);
            slidableController.activeState.close();
          },
        ));
  }

  void deleteMessage(PartialMessage partialMessage, int index) {
    showDialog(
      context: context,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        content: Text('Are you sure want to delete this Message?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            )),
        actions: <Widget>[
          FlatButton(
            child: const Text('YES'),
            color: darkBlue(),
            onPressed: () async {
              // call delete message _auth method
              bool done = false;
              if (done) {
                Navigator.pop(context);
                _showSnackBar(context, "Message is deleted successfully!!");
                setState(() {
                  messageList.removeAt(index);
                  if (messageList.length <= 9) {
                    getList();
                  }
                });
              } else {
                Navigator.pop(context);
                _showSnackBar(context, "Error");
              }
            },
          ),
          FlatButton(
            color: darkBlue(),
            child: const Text(
              'NO',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void showMaterialDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('You selected: $value'),
        ));
      }
    });
  }

  void showCuperDialog<T>({BuildContext context, Widget child}) {
    showCupertinoDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then((T value) {
      if (value != null) {}
    });
  }

  Widget _getSlidableWithLists(
      BuildContext context, PartialMessage partialMessage, int index) {
    return Slidable(
      key: Key(partialMessage.id),
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(partialMessage),
      actions: listActionSlideActions(partialMessage, index),
      secondaryActions: listSecondaryActions(partialMessage, index),
    );
  }

  Future showScaleAlertBox({
    @required BuildContext context,
    @required Widget yourWidget,
    Widget icon,
    Widget title,
    @required Widget firstButton,
    Widget secondButton,
  }) {
    assert(context != null, "context is null!!");
    assert(yourWidget != null, "yourWidget is null!!");
    assert(firstButton != null, "button is null!!");
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.7),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                title: title,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    icon,
                    Container(
                      height: 10,
                    ),
                    yourWidget
                  ],
                ),
                actions: <Widget>[
                  firstButton,
                  secondButton,
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.partialMessage);
  final PartialMessage partialMessage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed('/detail_message', arguments: {'id': partialMessage.id}),
      child: Container(
        color: lightBlue(),
        child: MessageTile(partialMessage: partialMessage),
      ),
    );
  }
}

enum LoadMoreData { LOADING, STABLE }
