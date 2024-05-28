import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/state_notifier.dart';
import '../../../../utils/colors.dart';
import '../models/UserAbout.dart';
import '../user_auth.dart';

class PickStateWidget extends StatefulWidget {
  bool disable;
  String?
      initialStateValue; // If we pass this value, it won't the state from the userbloc.
  Function(int? stateId, String? pickedStateValue) afterOnChanged;
  PickStateWidget(
      {Key? key,
      this.disable = false,
      this.initialStateValue,
      required this.afterOnChanged})
      : super(key: key);

  @override
  State<PickStateWidget> createState() => _PickStateWidgetState();
}

class _PickStateWidgetState extends State<PickStateWidget> {
  int? stateId;
  List<String> states = [];
  String? pickedStateValue;
  UserAbout? userBioDetail;
  bool disableDropDown = false; // Disable dropdown when it's loading.
  Map<int, String> statesMap = {};

  @override
  void initState() {
    super.initState();
    userBioDetail = Provider.of<UserBloc>(context, listen: false).userAbout;

    if (widget.initialStateValue == null) {
      if (userBioDetail?.userAddress?.state != null) {
        final dynamic state = userBioDetail!.userAddress!.state;
        if (state is Map) {
          stateId = state['id'];
          debugPrint('Fola states 0000::: ${state['id']}');
        } else {
          stateId = state;
        }
      }
    }

    getStates();
  }

  getStates({String? state}) {
    disableDropDown = true;
    if (mounted) setState(() {});
    UserAuth().getStates().then((value) {
      value.forEach((element) {
        states.add(element.name!);
        debugPrint('Fola states::: ${element.name!}');

        statesMap[element.id!] = element.name!;
      });

      pickedStateValue = widget.initialStateValue ?? statesMap[stateId];

      disableDropDown = false;
      if (mounted) setState(() {});
    }).catchError((e) {
      disableDropDown = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: addStateDropdown()),
        SizedBox(width: 12),
      ],
    );
  }

  Widget addStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'State',
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            border: Border.all(color: dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: IgnorePointer(
              ignoring: disableDropDown == true ? true : widget.disable,
              child: DropdownButton2(
                  isExpanded: true,
                  value: pickedStateValue,
                  underline: SizedBox.shrink(),
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                  ),
                  items: states.map((String item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    pickedStateValue = value;
                    final int id = statesMap.keys
                        .firstWhere((element) => statesMap[element] == value);
                    stateId = id;
                    if (mounted) setState(() {});
                    widget.afterOnChanged(stateId, pickedStateValue);
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
