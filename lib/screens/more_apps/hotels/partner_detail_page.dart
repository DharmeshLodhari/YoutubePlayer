import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

class PartnerDetailPage extends StatefulWidget {
  const PartnerDetailPage({super.key});

  @override
  State<PartnerDetailPage> createState() => _PartnerDetailPageState();
}

class _PartnerDetailPageState extends State<PartnerDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar() as PreferredSizeWidget?,
      backgroundColor: Colors.white,
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
        "Bond street dojo",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
      actions: [
        Row(
          children: [
            Icon(
              SlydoAppIcon.star,
              color: starYellow,
              size: 11,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              "7.8",
              style: TextStyle(
                  fontSize: 12, color: blackFont, fontWeight: FontWeight.w400),
            )
          ],
        ),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: <Widget>[
            partnerDetailTile(
                icon: SlydoAppIcon.achievement,
                iconColor: naturalGreen,
                title: "Renter friendly",
                detail:
                    "Bond street dojo is a trusted, verified Slydo partner"),
            const SizedBox(
              height: 12,
            ),
            partnerDetailTile(
                icon: SlydoAppIcon.partner,
                iconColor: navyBlue,
                title: "Tech-Savvy Partner",
                detail:
                    "Bond street dojo is a trusted, verified Slydo partner"),
            const SizedBox(
              height: 12,
            ),
            partnerDetailTile(
                icon: SlydoAppIcon.star,
                iconColor: starYellow,
                title: "Populer partner",
                detail: "This partner has helped ovr 866 renters on Slydo"),
            const SizedBox(
              height: 40,
            ),
            askQuestionBtn(),
          ],
        ),
      ),
    );
  }

  Widget partnerDetailTile(
      {required Color iconColor,
      IconData? icon,
      required String title,
      required String detail}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            RoundedBackgroundIcon(
              backgroundColor: iconColor.withOpacity(0.08),
              borderRadius: 12,
              height: 32,
              width: 32,
              icon: Icon(
                icon,
                size: 14,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 4,
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                detail,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w400, color: darkGrey),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget askQuestionBtn() {
    return OutlineCurvedButton(
      text: "Ask a question",
      onPressed: () {
        Navigator.of(context).pushNamed('/compose_message', arguments: {
          'recipient': "brijesh.sakariya",
          'subject': "",
        });
      },
      textColor: navyBlue,
    );
  }
}
