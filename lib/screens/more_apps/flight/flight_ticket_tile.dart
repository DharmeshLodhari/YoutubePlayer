import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

import '../messaging/chat/utils.dart';
import 'models/Transport.dart';

class FlightTicketTile extends StatelessWidget {
  final Transport? transport;

  const FlightTicketTile({Key? key, this.transport}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: decorateBox(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 20,
                width: 20,
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/singapore airlines.png",
                    height: double.infinity,
                    width: double.infinity,
                  ),
                )),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transport!.name!,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: blackFont,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        getUserCurrencySymbol(context),
                        Text(
                          transport!.price!,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: navyBlue,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      transport!.date!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: mateRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transport!.time!,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: blackFont,
                      ),
                    ),
                    Text(
                      transport!.travelTime!,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: darkGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "From",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: darkGrey,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          transport!.from!,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: blackFont,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "To",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: darkGrey,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          transport!.to!,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: blackFont,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
