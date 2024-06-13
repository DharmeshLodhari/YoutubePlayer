import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../utils/util.dart';
import '../../../../data/state_notifier.dart';
import '../../../../routes/route_constants.dart';
import '../auth/service_hub_auth.dart';
import '../models/jobs.dart';
import '../tiles/jos_description_card.dart';

class SearchMyJobs extends StatefulWidget {
  const SearchMyJobs({
    super.key,
  });

  @override
  _SearchMyJobsState createState() => _SearchMyJobsState();
}

class _SearchMyJobsState extends State<SearchMyJobs> {
  final GlobalKey<ScaffoldState> _scaffoldSearchKey =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerSearchKey =
      GlobalKey<ScaffoldMessengerState>();

  bool isLoading = false;
  int? count = 0;
  String? next = "";
  String? previous = "";
  List<JobModel> searchMyJobListing = [];
  final ScrollController _scrollController = ScrollController();
  bool noItemInList = false;
  bool isSearchIsEmpty = true;
  String username = "";

  TextEditingController searchController = TextEditingController();
  late UserBloc userBloc;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        if (next != null) {
          getList();
        }
      }
    });
    userBloc = Provider.of<UserBloc>(context, listen: false);

    username = userBloc.user.userName!;

    searchController.addListener(() {
      if (searchController.text.length <= 1) {
        setState(() {
          searchMyJobListing.clear();
        });
      }
      if (searchController.text.length >= 3) {
        setState(() {
          _refreshList();
        });
      }
      if (searchMyJobListing.isNotEmpty || searchController.text.isNotEmpty) {
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

  void _refreshList() {
    count = 0;
    next = "";
    previous = "";
    searchMyJobListing.clear();
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

        final result = await ServiceHubAuthService().searchMyJobListing(
          next,
          previous,
          username,
          searchController.text,
        );

        if (result == null) {
          isLoading = false;
          return;
        }

        count = result.count;
        next = result.next;
        previous = result.previous;
        final tempList = result.results;

        if (mounted) {
          isLoading = false;

          searchMyJobListing.addAll(tempList!);
          setState(() {});
        }
      }
      if (searchMyJobListing.isEmpty) {
        if (mounted) {
          noItemInList = true;
          setState(() {});
        }
      } else if (next == null && searchMyJobListing.length > 6) {
        _scaffoldMessengerSearchKey.currentState?.showSnackBar(
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

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      centerTitle: false,
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
            color: blackFont,
            fontSize: 18,
            fontFamily: "Inter",
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return Column(
      children: [
        const SizedBox(height: 6),
        searchBox(),
        const SizedBox(height: 12),
        if (isLoading)
          const CircularProgressIndicator()
        else
          const SizedBox.shrink(),
        if (isSearchIsEmpty)
          Expanded(
            child: NoItemInList(
              msg: AppLocalization.of(context)!.pleaseTypeSomethingToGetResult,
              isResult: false,
            ),
          )
        else
          noItemInList
              ? Expanded(
                  child: NoItemInList(
                    msg: AppLocalization.of(context)!.noResultFound,
                  ),
                )
              : Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                      itemCount: searchMyJobListing.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, Routes.MY_JOB_DETAILS,
                                arguments: {
                                  'jobId': searchMyJobListing[index].id,
                                  'listingId': '',
                                  'job': searchMyJobListing[index]
                                }),
                            child: JobDescriptionCard(
                              job: searchMyJobListing[index],
                            ),
                          ),
                        );
                      }),
                )
      ],
    );
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
                searchMyJobListing.clear();
                noItemInList = false;
                getList();
              });
            }
          },
          autofocus: true,
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontFamily: "Inter",
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
            hintText: "Search my jobs",
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
