import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/super_hub/tiles/jos_description_card.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

class JobsCategoryJobsList extends StatefulWidget {
  const JobsCategoryJobsList({super.key});

  @override
  State<JobsCategoryJobsList> createState() => _JobsCategoryJobsListState();
}

class _JobsCategoryJobsListState extends State<JobsCategoryJobsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.JOB_DETAILS),
                    child: const JobDescriptionCard(),
                  ),
                );
              }),
        ));
  }

  AppBar appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        "Service Hub",
        style: TextStyle(
          color: blackFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        _filterBtn(),
        const SizedBox(
          width: 12,
        )
      ],
    );
  }

  Widget _filterBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.filter,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        // Navigator.pushNamed(context, Routes.SEARCH_SERVICES);
      },
      backgroundColor: blackFont.withOpacity(0.1),
      enableMargin: true,
    );
  }
}
