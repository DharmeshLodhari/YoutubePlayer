import 'package:Slydo/screens/more_apps/events/models/partial_event_item.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../messaging/chat/utils.dart';

class EventTile extends StatelessWidget {
  final PartialEventItem? partialEventItem;

  const EventTile({super.key, this.partialEventItem});

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: partialEventItem!.image!,
                    fit: BoxFit.fill,
                    height: 86,
                    width: 68,
                    errorWidget: imageErrorWidget,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: SizedBox(
                    height: 86,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partialEventItem!.dateTime!,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: mateRed,
                          ),
                        ),
                        flexibleSpace(flex: 2),
                        Text(
                          partialEventItem!.name!,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: blackFont,
                          ),
                        ),
                        flexibleSpace(),
                        Text(
                          partialEventItem!.location!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: blackFont,
                          ),
                        ),
                        flexibleSpace(flex: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// ignore: must_be_immutable
class EventTileWithHeart extends StatefulWidget {
  final PartialEventItem? partialEvent;

  const EventTileWithHeart({super.key, this.partialEvent});
  @override
  State<EventTileWithHeart> createState() => _EventTileWithHeartState();
}

class _EventTileWithHeartState extends State<EventTileWithHeart> {
  bool isChange = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.partialEvent!.image!,
                  fit: BoxFit.fill,
                  height: 86,
                  width: 68,
                  errorWidget: imageErrorWidget,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: SizedBox(
                  height: 86,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.partialEvent!.dateTime!,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: mateRed,
                        ),
                      ),
                      flexibleSpace(flex: 2),
                      Text(
                        widget.partialEvent!.name!,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: blackFont,
                        ),
                      ),
                      flexibleSpace(),
                      Text(
                        widget.partialEvent!.location!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: blackFont,
                        ),
                      ),
                      flexibleSpace(flex: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          getUserCurrencySymbol(context),
                          Text(
                            widget.partialEvent!.price!,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: navyBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 86,
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      isChange
                          ? SlydoAppIcon.heart_empty
                          : SlydoAppIcon.heart_1,
                      color: isChange ? blackFont : navyBlue,
                      size: 20,
                    ),
                    onPressed: () {
                      isChange = !isChange;
                      setState(() {});
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
