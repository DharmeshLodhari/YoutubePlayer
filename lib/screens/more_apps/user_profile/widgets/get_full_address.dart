import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GetFullAddressWidget extends StatefulWidget {
  final UserAbout userAbout;
  const GetFullAddressWidget({Key? key, required this.userAbout})
      : super(key: key);

  @override
  _GetFullAddressWidgetState createState() => _GetFullAddressWidgetState();
}

class _GetFullAddressWidgetState extends State<GetFullAddressWidget> {
  int? stateId;
  String? stateName;
  bool isStateLoading = true;
  Map<int, String> statesMap = {};

  @override
  void initState() {
    super.initState();

    UserAbout? userAbout =
        Provider.of<UserBloc>(context, listen: false).userAbout;

    if (userAbout?.userAddress?.state != null) {
      stateId = userAbout!.userAddress!.state;
    }

    UserAuth().getStates().then((value) {
      value.forEach((element) {
        statesMap[element.id!] = element.name!;
      });

      stateName = statesMap[stateId];

      isStateLoading = false;
      if (mounted) setState(() {});
    }).catchError((e) {
      isStateLoading = false;
      if (mounted) setState(() {});
    });
  }

  String getFullAddress() {
    UserAddress? userAddress = widget.userAbout.userAddress;
    List<String> addresses = [];

    if (userAddress?.addressLine1 != null &&
        userAddress!.addressLine1!.isNotEmpty) {
      addresses.add(userAddress.addressLine1!);
    }
    if (userAddress?.addressLine2 != null &&
        userAddress!.addressLine2!.isNotEmpty) {
      addresses.add(userAddress.addressLine2!);
    }
    if (userAddress?.city != null && userAddress!.city!.isNotEmpty) {
      addresses.add(userAddress.city!);
    }
    if (stateName != null && stateName!.isNotEmpty) {
      addresses.add(stateName!);
    }

    return addresses.join(', ').replaceAll('.', '');
  }

  @override
  Widget build(BuildContext context) {
    return isStateLoading
        ? SizedBox(width: 20, height: 20, child: CircularLoadingIndicator())
        : Expanded(
            child: Text(
              getFullAddress(),
              // textAlign: TextAlign.justify,
            ),
          );
  }
}
