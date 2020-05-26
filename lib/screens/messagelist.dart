import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/message.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/message.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:toast/toast.dart';

class MessageList extends StatefulWidget {
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final GlobalKey<ScaffoldState> _scaffoldMessageKey =
      new GlobalKey<ScaffoldState>();
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
  String filterValue = "all";
  UserBloc userBloc;
  RefreshBlocForMessages _refreshBloc;

  @protected
  void initState() {
    this.getList();

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

  // refresh the list when lifecycle called onResume method
  void _onRefreshOnResume() {
    _refreshBloc = Provider.of<RefreshBlocForMessages>(context);
    _refreshBloc
      ..addListener(() {
        if (_refreshBloc.isRefresh) {
          if (mounted) {
            _onRefresh();
            _refreshBloc.isRefresh = false;
          }
        }
      });
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
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    // refresh the list when lifecycle called onResume method
    _onRefreshOnResume();

    return Scaffold(
      key: _scaffoldMessageKey,
      backgroundColor: lightBlue(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: darkBlue(),
        title: Text(AppLocalization.of(context).messages),
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
        heroTag: "compose_message",
        backgroundColor: darkBlue(),
        child: Icon(Icons.message),
        onPressed: () {
          Navigator.of(context).pushNamed("/compose_message");
        },
      ),
    );
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
                  Text(AppLocalization.of(context).filter),
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
                AppLocalization.of(context).all,
                style: TextStyle(color: Colors.black),
              ),
              value: "all",
              checked: filterValue == "all" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).archived,
                style: TextStyle(color: Colors.black),
              ),
              value: "archived",
              checked: filterValue == "archived" ? true : false,
            ),
          );

          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).sent,
                style: TextStyle(color: Colors.black),
              ),
              value: "sent",
              checked: filterValue == "sent" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).starred,
                style: TextStyle(color: Colors.black),
              ),
              value: "starred",
              checked: filterValue == "starred" ? true : false,
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
            msg: AppLocalization.of(context).noMessages,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
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
                ? CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
                  )
                : Container()),
      ),
    );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic> result =
            await _auth.listMessages(next, previous, filter: filterValue);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            noItemInList = false;
            isLoading = false;
            messageList.addAll(tempList);
          });
        }
      }
      if (messageList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && messageList.length > 6) {
        _scaffoldMessageKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
          getList();
        });
      }
    }
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldMessageKey.currentState
        .showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listActionSlideActions(
      PartialMessage partialMessage, int index) {
    return [displayArchivedUnArchivedButton(partialMessage, index)];
  }

  Widget displayArchivedUnArchivedButton(
      PartialMessage partialMessage, int index) {
    // this variable is responsible for the message which is user seeing isRecipient is seeing message
    // or isSender is seeing message we got that user and check if it is recipient then
    // we are showing and modifying archive icon by message's isArchivedByRecipient property and if it sender then
    // we are showing and modifying archive icon by message's isArchivedBySender property
    bool isRecipient = userBloc.user.userName == partialMessage.recipient;
    return Container(
        height: double.infinity,
        color: Colors.green,
        child: IconButton(
          icon: isRecipient
              ? partialMessage.isArchivedByRecipient
                  ? Icon(
                      Icons.archive,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.unarchive,
                      color: Colors.white,
                    )
              : partialMessage.isArchivedBySender
                  ? Icon(
                      Icons.archive,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.unarchive,
                      color: Colors.white,
                    ),
          onPressed: () async {
            var action = isRecipient
                ? partialMessage.isArchivedByRecipient
                    ? AppLocalization.of(context).unarchive
                    : AppLocalization.of(context).archive
                : partialMessage.isArchivedBySender
                    ? AppLocalization.of(context).unarchive
                    : AppLocalization.of(context).archive;
            await _auth.updateMessage(partialMessage.id, action);
            setState(() {
              if (isRecipient) {
                partialMessage.isArchivedByRecipient =
                    partialMessage.isArchivedByRecipient ? false : true;
              } else {
                partialMessage.isArchivedBySender =
                    partialMessage.isArchivedBySender ? false : true;
              }
            });
            slidableController.activeState.close();
          },
        ));
  }

  void markArchivedUnArchivedMessage(PartialMessage partialMessage, int index) {
    setState(() {
      partialMessage.isArchivedByRecipient =
          partialMessage.isArchivedByRecipient ? false : true;
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

  void deleteMessage(PartialMessage partialMessage, int index) async {
    bool result = await showDialogBox(
      context: context,
      title: AppLocalization.of(context).delete,
      description: AppLocalization.of(context).areYouSureWantToDeleteThisMsg,
      actionOne: AppLocalization.of(context).yes,
      actionTwo: AppLocalization.of(context).cancel,
      type: AlertType.warning,
    );
    if (result) {
      // call delete message _auth method
      bool done = await _auth.deleteMessage(messageList[index].id);
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context).messageIsDeletedSuccessfully);
        setState(() {
          messageList.removeAt(index);
          if (messageList.length <= 9) {
            getList();
          }
        });
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
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
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem(this.partialMessage);
  final PartialMessage partialMessage;

  @override
  _VerticalListItemState createState() => _VerticalListItemState();
}

class _VerticalListItemState extends State<VerticalListItem> {
  final _auth = AuthService();
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pushNamed('/detail_message',
            arguments: {'id': widget.partialMessage.id});
      },
      onLongPress: () {
        setState(() {
          if (isExpanded) {
            isExpanded = false;
          } else {
            isExpanded = true;
          }
        });
      },
      child: Container(
        color: lightBlue(),
        child: MessageTile(
            partialMessage: widget.partialMessage,
            isExpanded: isExpanded,
            expandedWidget: expandedWidget()),
      ),
    );
  }

  Widget expandedWidget() {
    return Container(
      height: 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 0.5,
            color: darkBlue(),
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(child: sendMessageButton()),
                Container(
                  width: 0.5,
                  color: darkBlue(),
                  height: 40,
                ),
                Expanded(child: blockUserButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sendMessageButton() {
    return MaterialButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.message,
            color: darkBlue(),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "Message",
            style: TextStyle(color: darkBlue()),
          ),
        ],
      ),
      onPressed: () {
        _auth.fetchCustomerProfile(widget.partialMessage.sender).then((user) {
          setState(() {
            isExpanded = false;
          });
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': user.userName,
            'subject': "",
          });
        });
      },
    );
  }

  Widget blockUserButton() {
    return MaterialButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Icon(
                Icons.group,
                color: Colors.black,
              ),
              Icon(
                Icons.block,
                color: Colors.red,
              )
            ],
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "Block User",
            style: TextStyle(color: Colors.redAccent),
          ),
        ],
      ),
      onPressed: () {
        _auth.fetchCustomerProfile(widget.partialMessage.sender).then((user) {
          _auth.blockUser(user).then((result) {
            setState(() {
              isExpanded = false;
            });
            if (result) {
              Toast.show("${widget.partialMessage.sender} is Blocked", context);
            } else {
              Toast.show("Error occurs", context);
            }
          });
        });
      },
    );
  }
}
