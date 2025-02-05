import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/service_hub/models/active_job_listing.dart';
import 'package:Slydo/screens/service_hub/tiles/jos_description_card.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/state_notifier.dart';
import '../../../../widget/debouncer_widget.dart';

class JobsSearch extends StatefulWidget {
  const JobsSearch({super.key, this.filterMap});
  final Map<String, dynamic>? filterMap;

  @override
  State<JobsSearch> createState() => _JobsSearchState();
}

class _JobsSearchState extends State<JobsSearch> {
  bool isLoading = false;
  int? count = 0;
  String? next = "";
  String? previous = "";
  bool noItemInList = false;
  bool isSearchIsEmpty = true;
  List<ActiveListingData> jobsList = [];
  final TextEditingController searchController = TextEditingController();
  int counter = 0;
  String category = "";
  String sortby = "";
  String priceFrom = "";
  String priceTo = "";
  String location = "";
  Map<String, dynamic> sortMap = {
    'Oldest': 'created_at',
    'Most Recent': '-created_at',
    'Price High to Low': '-job__pay',
    'Price Low to High': 'job__pay',
  };

  late UserBloc userBloc;
  final _debouncer = Debouncer(milliseconds: 500);

  void getJobListing() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        final result = await ServiceHubAuthService().getActiveJobListing(
            next, previous,
            search: searchController.text,
            category: widget.filterMap?['category'] ?? category,
            sortBy: widget.filterMap?['sortby'] ?? sortby,
            priceFrom: widget.filterMap?['priceFrom'] ?? priceFrom,
            priceTo: widget.filterMap?['priceTo'] ?? priceTo,
            location: widget.filterMap?['location'] ?? location);

        if (result == null) {
          if (mounted) {
            noItemInList = true;

            isLoading = false;
            setState(() {});
          }
          return;
        }

        count = result.count;
        next = result.next;
        previous = result.previous;
        final tempList = result.results;
        if (mounted) {
          setState(() {
            isSearchIsEmpty = false;
            noItemInList = false;
            isLoading = false;
            jobsList.addAll(tempList!);
          });
        }
      }
      if (jobsList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && jobsList.length > 6) {
        // _productScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        //   content:
        //       Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
        //   duration: Duration(milliseconds: 500),
        // ));
      }
    }
  }

  @override
  void initState() {
    getJobListing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
            color: blackFont,
            fontSize: 18,
            fontFamily: "Inter",
            fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, Routes.JOB_SEARCH_FILTER)
              .then((value) {
            final Map<String, dynamic> filterData =
                value as Map<String, dynamic>;
            // debugPrint('stores map ${searchController.text}');

            category = filterData['category'];
            if (filterData['sortby'] != '') {
              sortby = sortMap[filterData['sortby']];
            }

            priceFrom = filterData['priceFrom'];
            priceTo = filterData['priceTo'];
            location = filterData['location'];
            count = 0;
            next = "";
            previous = "";
            jobsList.clear();
            noItemInList = false;
            if (mounted) setState(() {});

            getJobListing();
          }),
          child: Icon(
            SlydoAppIcon.filter,
            size: 16,
            color: blackFont,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget scaffoldBody() {
    return Column(
      children: [
        // showSortByBox ? sortByDropDown() : SizedBox.shrink(),
        const SizedBox(height: 6),
        searchBox(),
        const SizedBox(height: 12),
        if (isLoading)
          Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: greyBorderColor,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 14,
                mainAxisExtent: 180,
                crossAxisSpacing: 15,
                maxCrossAxisExtent: 200,
              ),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          )
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
              : Expanded(
                  child: ListView(
                      children: jobsList
                          .map(
                            (job) => Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: GestureDetector(
                                onTap: () {
                                  userBloc.user.userName == job.job!.owner
                                      ? Navigator.pushNamed(
                                          context, Routes.MY_JOB_DETAILS,
                                          arguments: {
                                              'jobId': job.job!.id,
                                              'listingId': job.id,
                                              'job': job.job
                                            })
                                      : Navigator.pushNamed(
                                          context, Routes.JOBS_PREVIEW_DETAIL,
                                          arguments: {
                                              'jobId': job.job!.id,
                                              'listingId': job.id,
                                              'job': job.job
                                            });
                                },
                                child: JobDescriptionCard(
                                  job: job.job,
                                ),
                              ),
                            ),
                          )
                          .toList()),
                ),
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
          key: const ValueKey('Search'),
          controller: searchController,
          onChanged: (value) {
            if (value.length >= 3) {
              _debouncer.run(() {
                setState(() {
                  count = 0;
                  next = "";
                  previous = "";
                  jobsList.clear();
                  noItemInList = false;
                  getJobListing();
                });
              });
            }
          },
          onFieldSubmitted: (val) {},
          autofocus: true,
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Inter",
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              fontSize: 14,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
              color: darkGrey,
            ),
            hintText: "",
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
