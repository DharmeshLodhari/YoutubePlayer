import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../utils/util.dart';
import '../../user_profile/models/user.dart';
import '../yarn_auth.dart';

class AskMentionView extends StatefulWidget {
  final String? searchText;
  final Function(String?) onTap;

  AskMentionView({
    required this.onTap,
    required this.searchText,
    super.key,
  });

  @override
  State<AskMentionView> createState() => _AskMentionViewState();
}

class _AskMentionViewState extends State<AskMentionView> {
  bool isLoading = false, noList = false;
  String? next = '', previous = '', subString;
  int? count = 0;
  List<CustomerProfile> customerProfiles = [];
  final ScrollController _userScrollController = ScrollController();

  @override
  void initState() {
    getSearchUser(widget.searchText ?? '');
    _userScrollController.addListener(() {
      if (_userScrollController.position.pixels ==
              _userScrollController.position.maxScrollExtent &&
          _userScrollController.position.pixels != 0) {
        getSearchUser(widget.searchText ?? '');
      }
    });
    super.initState();
  }

  void cleanList() {
    next = '';
    previous = '';
    noList = true;
    count = 0;
    customerProfiles.clear();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _buildListContainer();
  }

  Widget _buildListContainer() {
    if (customerProfiles.isEmpty) {
      return Container();
    } else {
      return Container(
        height: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: HexColor("#E9E9E9"))),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: customerProfiles.length,
          itemBuilder: (context, index) {
            return _buildUserListTile(customerProfiles[index]);
          },
        ),
      );
    }
  }

  Widget _buildUserListTile(CustomerProfile customerProfile) {
    return InkWell(
      onTap: () {
        widget.onTap(customerProfile.userName);
        cleanList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: white,
        ),
        child: Row(
          children: [
            getUserLeading(customerProfile),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userNameWithVerifiedIcon(
                    name: customerProfile.fullName!,
                    isVerified: customerProfile.isVerified,
                    textStyle: TextStyle(
                      fontSize: 10,
                      color: blackFont,
                    )),
                Text(
                  "@${customerProfile.userName ?? ''}",
                  maxLines: 1,
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getUserLeading(CustomerProfile customerProfile) {
    final Color borderColor = getUserTypeColor(user: customerProfile);

    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            25,
          ),
          border: Border.all(color: borderColor, width: 2)),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: customerProfile.avatar == ""
              ? defaultImage
              : customerProfile.avatar!,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.cover,
          errorWidget: imageErrorWidget,
          height: double.infinity,
          filterQuality: FilterQuality.high,
          placeholder: (context, _) => CachedNetworkImage(
            imageUrl: defaultImage,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }

  void getSearchUser(String searchText) async {
    debugPrint("IS LOADING:- $isLoading");
    if (!isLoading) {
      debugPrint("NEXT:- $next");
      if (next != null && !isLoading) {
        isLoading = true;
        if (mounted) setState(() {});

        final Map<String, dynamic>? result =
            await YarnAuth().searchUser(next, previous ?? '', searchText);

        debugPrint("RESULTS:- $result");
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
        final tempList = result['results'];
        // yarnTopicList = [];
        if (mounted) {
          setState(() {
            noList = false;
            isLoading = false;
            customerProfiles.addAll(tempList);
          });
        }
        debugPrint("YARN TOPICS:- $customerProfiles");
      }
    }
    if (customerProfiles.isEmpty) {
      if (mounted) {
        setState(() {
          noList = true;
          next = "";
          previous = "";
        });
      }
    } else if (next == null && customerProfiles.length > 6) {
      // _askCategoriesScaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      //   content:
      //   Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
      //   duration: Duration(milliseconds: 500),
      // ));
    }
  }
}
