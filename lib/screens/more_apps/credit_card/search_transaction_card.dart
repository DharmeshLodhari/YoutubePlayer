import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/credit_card/auth/debit_card_auth.dart';
import 'package:Slydo/screens/more_apps/credit_card/models/card_transactions.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:flutter/material.dart';
import '../../../../../utils/util.dart';
import '../payment_and_banking/tiles/transaction.dart';


class SearchTransactionCard extends StatefulWidget {
  var arguments;

  SearchTransactionCard({this.arguments, Key? key}) : super(key: key);

  @override
  SearchTransactionCardState createState() => SearchTransactionCardState();
}

class SearchTransactionCardState extends State<SearchTransactionCard> {


  List<CardTransactions> transactionList = [];

  final GlobalKey<ScaffoldState> _scaffoldSearchKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerSearchKey =
  GlobalKey<ScaffoldMessengerState>();

  bool isLoading = false;

  //pagination variables
  int? count = 0;
  String? next = "";
  String? previous = "";
  String? cardId = "";
  final ScrollController _scrollController = ScrollController();
  bool noItemInList = false;
  bool isSearchIsEmpty = true;
  String autoCompleteSearchText = "";
  TextEditingController searchController = TextEditingController();


  @override
  void initState() {

    cardId = widget.arguments["data"];

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        if (next != null) {
          getList();
        }
      }
    });

    searchController.addListener(() {
      if (searchController.text.length >= 3) {
        setState(() {
          _refreshList();
        });
      }
      if (transactionList.isNotEmpty || searchController.text.length != 0) {
        if (mounted) {
          setState(() {
            isSearchIsEmpty = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isSearchIsEmpty = true;
          });
        }
      }
    });
    super.initState();
  }

  _refreshList() {
    count = 0;
    next = "";
    previous = "";
    transactionList.clear();
    noItemInList = false;
    getList();
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          isLoading = true;
          setState(() {});
        }

        Map<String, dynamic>? result =
        await DebitCardAuth().searchSingleCardsTransactions(
          next,
          previous,
          cardId,
          searchController.text,
        );


        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List? tempList = result['results'];
        // debugPrint('TEMP LIST --> $tempList');
        if (mounted) {
          isLoading = false;
          try {
            tempList!.forEach((result) {
              transactionList.add(result);
            });
          } catch (e) {
            debugPrint("error adding products $e");
          }
          setState(() {});
          debugPrint("ALL $transactionList");
        }
      }
      if (transactionList.isEmpty) {
        if (mounted) {
          noItemInList = true;
          setState(() {});
        }
      } else if (next == null && transactionList.length > 6) {
        _scaffoldMessengerSearchKey.currentState!.showSnackBar(
          SnackBar(
            content: Text(
                AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerSearchKey,
      child: Scaffold(
        key: _scaffoldSearchKey,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  bool showSortByBox = false;
  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
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
      title: Text(
        "Search",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      // actions: <Widget>[
      //   transactionList.isNotEmpty
      //       ? RoundedBackgroundIcon(
      //     height: 34,
      //     width: 34,
      //     icon: Icon(
      //       SlydoAppIcon.filter,
      //       size: 16,
      //       color: blackFont,
      //     ),
      //     onTap: () {
      //       setState(() {
      //         showSortByBox = !showSortByBox;
      //       });
      //     },
      //     backgroundColor: iconBtnGrey,
      //     enableMargin: true,
      //   )
      //       : const SizedBox.shrink(),
      //   const SizedBox(width: 16),
      // ],
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        children: [

          const SizedBox(height: 6),
          searchBox(),
          const SizedBox(height: 12),
          isLoading ? const CircularProgressIndicator() : const SizedBox.shrink(),
          isSearchIsEmpty
              ? Expanded(
            child: NoItemInList(
              msg: AppLocalization.of(context)!
                  .pleaseTypeSomethingToGetResult,
              isResult: false,
            ),
          )
              : noItemInList
              ? Expanded(
            child: NoItemInList(
              msg: AppLocalization.of(context)!.noResultFound,
            ),
          )
              : Expanded(
            child: ListView(
                children: transactionList
                    .map(
                      (transaction) => Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 10),
                    child: Container(
                      // margin: const EdgeInsets.all(8.0),
                      child: showCardTransaction(transaction),
                    ),

                  ),
                )
                    .toList()),
          ),
        ],
      ),
    );
  }

  Widget showCardTransaction(CardTransactions? transaction) {
    return CardTransactionTile(
      transaction: transaction!,
      expandedWidget: expandedWidget(),
    );
  }

  Widget expandedWidget() {
    return Container();
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: navyBlue,
          ),
        ),
        child: TextFormField(
          controller: searchController,
          onFieldSubmitted: (val) {
            if (mounted) {
              setState(() {
                count = 0;
                next = "";
                previous = "";
                transactionList.clear();
                noItemInList = false;
                getList();
              });
            }
          },
          autofocus: true,
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
            hintText: "Search Transaction",
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 16),
            ),
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
        ),
      ),
    );
  }


}
