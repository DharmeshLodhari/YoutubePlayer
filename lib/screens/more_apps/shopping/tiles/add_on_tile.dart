import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AddOnTile extends StatefulWidget {
  const AddOnTile({required this.addOns, super.key});

  final AddOns addOns;

  @override
  State<AddOnTile> createState() => _AddOnTileState();
}

class _AddOnTileState extends State<AddOnTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appendStringDot(widget.addOns.name!, 15),
                    maxLines: 1,
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: navyBlue),
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                      color:
                          widget.addOns.isRequired == true ? navyBlue : white,
                    ),
                    child: Text(
                      widget.addOns.isRequired == true
                          ? 'Required'
                          : 'Optional',
                      maxLines: 1,
                      style: TextStyle(
                          color: widget.addOns.isRequired == true
                              ? white
                              : navyBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 10),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(
              height: 0,
              color: dividerColor,
              thickness: 1,
            ),
            ...widget.addOns.options
                    ?.map(
                        (option) => _displayAddOnOption(option, widget.addOns))
                    .toList() ??
                []
          ],
        ),
      ),
    );
  }

  Widget _displayAddOnOption(AddOnOption addOnOption, AddOns addOns) {
    return Container(
      padding: EdgeInsets.only(top: 15, right: 16, left: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (addOnOption.picture != null)
                InkWell(
                  onTap: () {
                    showDescription(addOnOption);
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: dividerColor,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: CachedNetworkImage(
                        imageUrl: addOnOption.picture!,
                        fit: BoxFit.fill,
                        errorWidget: productAndServiceErrorWidget,
                      ),
                    ),
                  ),
                ),
              SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: () {
                    if (addOnOption.picture == null) {
                      showDescription(addOnOption);
                    }
                  },
                  child: Text(
                    appendStringDot(addOnOption.name!, 100),
                    maxLines: 2,
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ),
              ),
              Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildPriceForAddOn(addOnOption: addOnOption),
                      SizedBox(
                        width: 8,
                      ),
                      _buildAddOnSelection(
                          addOnOption: addOnOption, addOns: addOns),
                    ],
                  ),
                  if (addOns.inputType == "radio" &&
                          addOns.groupValue == addOnOption.name ||
                      addOns.inputType == "checkbox" &&
                          addOnOption.isChecked == true)
                    _buildQtySelection(addOnOption: addOnOption, addOns: addOns)
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
          Divider(
            height: 0,
            color: dividerColor,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildQtySelection(
      {required AddOnOption addOnOption, required AddOns addOns}) {
    if (addOnOption.selectType == "multiple") return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 8,
        ),
        Container(
          width: 80,
          color: Colors.transparent,
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RoundedBackgroundIcon(
                  backgroundColor: iconBtnGrey,
                  height: 25,
                  width: 25,
                  borderRadius: 6,
                  icon: Icon(
                    SlydoAppIcon.minus,
                    color: blackFont,
                    size: 1.5,
                  ),
                  onTap: () {
                    if (addOnOption.quantity > 1) {
                      addOnOption.quantity -= 1;
                    } else {
                      addOnOption.isChecked = false;
                      addOns.groupValue = null;
                      addOnOption.quantity = 0;
                    }
                    setState(() {});
                  },
                ),
                Expanded(
                  child: SizedBox(
                    width: 10,
                  ),
                ),
                Text(
                  addOnOption.quantity.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: blackFont,
                    fontFamily: "Inter",
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: 10,
                  ),
                ),
                RoundedBackgroundIcon(
                  backgroundColor: iconBtnGrey,
                  height: 25,
                  width: 25,
                  borderRadius: 6,
                  icon: Icon(
                    SlydoAppIcon.plus,
                    color: blackFont,
                    size: 10, // Adjust the size as needed
                  ),
                  onTap: () {
                    addOnOption.quantity += 1;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceForAddOn({required AddOnOption addOnOption}) {
    return Row(
      children: [
        Text(
          '(${worldCurrencies[addOnOption.currency!]!}',
          style: TextStyle(
              fontFamily: "Inter",
              fontSize: 14.0,
              color: blackFont.withOpacity(.5),
              fontWeight: FontWeight.w500),
        ),
        Text(
          '${moneyDisplayNormalizer(int.parse(addOnOption.price.toString()))})',
          style: TextStyle(
              fontSize: 14.0,
              color: darkGrey,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500),
        )
      ],
    );
  }

  Widget _buildAddOnSelection({
    required AddOns addOns,
    required AddOnOption addOnOption,
  }) {
    if (addOns.inputType == 'checkbox') {
      return Checkbox(
        visualDensity: const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: addOnOption.isChecked,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        side: BorderSide(width: 1, color: darkGrey),
        activeColor: navyBlue,
        onChanged: (bool? value) {
          // Handle checkbox state change here
          // addOns.options!.forEach((data) {
          //   if (data.id == addOnOption.id) {
          // Found the option with the target ID, change its isChecked value
          addOnOption.isChecked = !addOnOption.isChecked;
          addOnOption.quantity = 1;
          //   }
          // });
          if (mounted) setState(() {});
        },
      );
    }

    if (addOns.inputType == 'radio') {
      return Radio<String>(
        visualDensity: const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        value: addOnOption.name ?? "",
        groupValue: addOns.groupValue,
        // You need to provide a unique group value for the radio buttons
        activeColor: navyBlue,
        onChanged: (String? value) {
          addOns.groupValue = value;
          addOnOption.quantity = 1;
          setState(() {});
        },
      );
    }

    return Container();
  }

  void showDescription(AddOnOption addOnOption) {
    showDialog<String>(
        barrierDismissible: true,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(21.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              addOnOption.picture != null
                                  ? Row(
                                      children: [
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: dividerColor,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            child: CachedNetworkImage(
                                              imageUrl: addOnOption.picture!,
                                              fit: BoxFit.fill,
                                              errorWidget:
                                                  productAndServiceErrorWidget,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              addOnOption.name!,
                                              style: TextStyle(
                                                  color: blackFont,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Inter'),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              '${worldCurrencies[addOnOption.currency!]!}${moneyDisplayNormalizer(int.parse(addOnOption.price.toString()))}',
                                              style: TextStyle(
                                                  color: darkGrey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Inter'),
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          addOnOption.name!,
                                          style: TextStyle(
                                              color: blackFont,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Inter'),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          '${worldCurrencies[addOnOption.currency!]!}${moneyDisplayNormalizer(int.parse(addOnOption.price.toString()))}',
                                          style: TextStyle(
                                              color: darkGrey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Inter'),
                                        )
                                      ],
                                    ),
                              SizedBox(height: 16),
                              Text(
                                "Description",
                                style: TextStyle(
                                    color: blackFont,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter'),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                addOnOption.description!,
                                style: TextStyle(
                                    color: darkGrey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter'),
                              )
                            ]),
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }
}
