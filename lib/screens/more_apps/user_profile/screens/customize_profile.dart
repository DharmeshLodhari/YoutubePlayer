import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../locale/app_localization.dart';
import '../../../../widget/curved_btn.dart';
import '../../../../widget/customized_textform_field.dart';
import '../models/custom_profile_model.dart';
import '../user_auth.dart';

class CustomizeProfileScreen extends StatefulWidget {
  final dynamic arguments;

  const CustomizeProfileScreen({required this.arguments, super.key});

  @override
  CustomizeProfileScreenState createState() => CustomizeProfileScreenState();
}

class CustomizeProfileScreenState extends State<CustomizeProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldGeneralSettingKey =
      GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  late UserBloc userBloc;
  final _auth = UserAuth();
  bool isLoading = false;
  bool isAPILoading = false;
  bool saveRequired = false;
  bool reloadPreviousPage = false;
  CustomProfileModel customProfileModel = CustomProfileModel();
  // Create a new map to store boolean values
  Map<String, bool> boolMap = {};
  List<String> orderedKeys = <String>[];
  String productLabel = "";
  String serviceLabel = "";
  final TextEditingController productLabelController = TextEditingController();
  final TextEditingController serviceLabelController = TextEditingController();
  Map<String, bool> reorderedBoolMap = {};
  Function(Map<String, dynamic>)? callbackProductService;

  @override
  void initState() {
    isLoading = true;
    getCustomizeProfile();
    callbackProductService = widget.arguments['callbackProductService'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    // final Function(Map<String, dynamic>) callbackProductService = widget.arguments['callbackProductService'];

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, reorderedBoolMap);
        return true;
      },
      child: Scaffold(
        key: _scaffoldGeneralSettingKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget scaffoldBody() {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<MapEntry<String, bool>> entries =
        reorderedBoolMap.entries.toList();
    final bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final String key = entries[index].key;
                final bool value = entries[index].value;

                return ReorderableDragStartListener(
                  key: ValueKey(key), // Assign a key based on the 'key' string
                  index: index,
                  child: getTile(
                    titleText: capitalizeAndRemoveUnderscores(key),
                    switchValue: value,
                    onTapCallback: (newValue) {
                      setState(() {
                        reorderedBoolMap[key] = newValue;
                        saveRequired = true;
                      });
                    },
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final entry = entries.removeAt(oldIndex);
                  entries.insert(newIndex, entry);
                  reorderedBoolMap = Map.fromEntries(entries);
                  saveRequired = true;
                });
              },
            ),
            if (widget.arguments['business'] == 'yes') ...[
              Form(
                key: _formKey,
                child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
                    child: Column(
                      children: [
                        addProductLabelField(),
                        const SizedBox(
                          height: 10,
                        ),
                        addServiceLabelField(),
                        const SizedBox(
                          height: 40,
                        ),
                      ],
                    )),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, reorderedBoolMap);
        },
      ),
      centerTitle: false,
      title: Text(
        "Customise Profile",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        if (saveRequired) ...[
          saveBtn(),
        ],
      ],
    );
  }

  Widget getTile({
    required String titleText,
    required bool switchValue,
    required Function(bool)? onTapCallback,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          title: Text(
            titleText, // Use the passed title dynamically
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: SizedBox(
            width: 40,
            height: 30,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch(
                value:
                    switchValue, // Set the Switch value based on the boolean parameter
                onChanged: onTapCallback, // Use the passed onTap function
                thumbIcon: MaterialStateProperty.all(const Icon(null)),
                activeTrackColor: navyBlue,
                activeColor: Colors.white,
                inactiveTrackColor: darkGreyYarn,
                inactiveThumbColor: Colors.white,
              ),
            ),
          ),
          onTap: () {
            // Handle the onTap behavior here, if needed
            if (onTapCallback != null) {
              onTapCallback(
                  !switchValue); // You can also toggle the boolean value
            }
          },
        ),
      ),
    );
  }

  Widget addProductLabelField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: CustomizedTextFormField(
        labelText: AppLocalization.of(context)!.productLabel,
        controller: productLabelController,
        validator: (val) {
          if (val.isNotEmpty) {
            return null;
          }
          return AppLocalization.of(context)!.pleaseEnterProductLabel;
        },
        onChanged: (val) {
          handleProductLabelChange(val);
        },
      ),
    );
  }

  Widget addServiceLabelField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: CustomizedTextFormField(
        labelText: AppLocalization.of(context)!.serviceLabel,
        controller: serviceLabelController,
        validator: (val) {
          if (val.isNotEmpty) {
            return null;
          }
          return AppLocalization.of(context)!.pleaseEnterServiceLabel;
        },
        onChanged: (val) {
          handleServiceLabelChange(val);
        },
      ),
    );
  }

  Future<void> getCustomizeProfile() async {
    final Map<String, dynamic>? result = await _auth.customizeProfile();

    if (result == null || result.isEmpty) {
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
      return;
    }

    customProfileModel = CustomProfileModel.fromJson(result['results']);

    productLabel = customProfileModel.productLabel!;
    serviceLabel = customProfileModel.serviceLabel!;
    productLabelController.text = customProfileModel.productLabel!;
    serviceLabelController.text = customProfileModel.serviceLabel!;

    // Iterate through the JSON object and filter boolean values
    result['results'].forEach((key, value) {
      if (value is bool) {
        boolMap[key] = value;
      }
    });

    // Iterate through the 'ordering' array and add keys that exist in boolMap to orderedKeys
    result['results']['ordering'].forEach((key) {
      if (boolMap.containsKey(key)) {
        orderedKeys.add(key);
      }
    });

    // Create a list of keys not in 'ordering'
    final remainingKeys =
        boolMap.keys.where((key) => !orderedKeys.contains(key)).toList();

    // Add the remaining keys to orderedKeys to ensure they are at the end
    orderedKeys.addAll(remainingKeys);

    // Create a new map with the ordered keys
    reorderedBoolMap =
        Map.fromEntries(orderedKeys.map((key) => MapEntry(key, boolMap[key]!)));

    if (widget.arguments['business'] == 'no') {
      final List<String> keysToRemove = [
        'product',
        'service',
        'reviews',
        'opening_hours'
      ];

      for (var key in keysToRemove) {
        reorderedBoolMap.remove(key);
      }
    }

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  // Callback for bool list any changes
  void handleBoolChange(String key, bool newValue) {
    setState(() {
      boolMap[key] = newValue;
      saveRequired = true;
    });
  }

  // Callback for text field changes
  void handleProductLabelChange(String newValue) {
    setState(() {
      productLabel = newValue;
      saveRequired = true;
    });
  }

  // Callback for text field changes
  void handleServiceLabelChange(String newValue) {
    setState(() {
      serviceLabel = newValue;
      saveRequired = true;
    });
  }

  Future<void> updateCustomizeProfile() async {
    if (widget.arguments['business'] == 'no') {
      isLoading = true;
      if (mounted) setState(() {});

      final Map<String, bool> currentArrangement = getCurrentBoolArrangement();
      final List<String> orderingList = currentArrangement.keys
          .where((key) => key != 'reviews' && key != 'opening_hours')
          .toList();

      final Map<String, dynamic> result = {
        "ordering": orderingList,
        "product_label": productLabel,
        "service_label": serviceLabel,
      };

      // Iterate through the existing map and add each entry to the result map
      currentArrangement.forEach((key, value) {
        result[key] = value;
      });

      await _auth.updateCustomizeProfile(result).then((value) {
        if (value == true) {
          reloadPreviousPage = true;
          saveRequired = false;
          showToast(message: "Profile Customization Updated");
          return true;
        } else {
          showToast(message: "Profile Customization Failed");
          return true;
        }
      }).catchError((error) {
        debugPrint(error.toString());
        showToast(message: error.toString());
      });

      isLoading = false;
      if (mounted) setState(() {});
      return;
    }

    if (_formKey.currentState!.validate()) {
      isLoading = true;
      if (mounted) setState(() {});

      final Map<String, bool> currentArrangement = getCurrentBoolArrangement();
      final List<String> orderingList = currentArrangement.keys
          .where((key) => key != 'reviews' && key != 'opening_hours')
          .toList();

      final Map<String, dynamic> result = {
        "ordering": orderingList,
        "product_label": productLabel,
        "service_label": serviceLabel,
      };

      // Iterate through the existing map and add each entry to the result map
      currentArrangement.forEach((key, value) {
        result[key] = value;
      });

      // debugPrint('Fola bool result::: ${result}');

      await _auth.updateCustomizeProfile(result).then((value) {
        if (value == true) {
          reloadPreviousPage = true;
          saveRequired = false;
          if (callbackProductService != null) {
            callbackProductService!(result);
          }

          showToast(message: "Profile Customization Updated");
          return true;
        } else {
          showToast(message: "Profile Customization Failed");
          return true;
        }
      }).catchError((error) {
        debugPrint(error.toString());
        showToast(message: error.toString());
      });

      isLoading = false;
      if (mounted) setState(() {});
    }
  }

  Map<String, bool> getCurrentBoolArrangement() {
    return reorderedBoolMap;
  }

  Widget saveBtn() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 34),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 240),
      child: CurvedButton(
        height: 32,
        textColor: Colors.white,
        backgroundColor: navyBlue,
        text: "Save",
        fontSize: 10,
        borderRadius: 20,
        isLoading: isAPILoading,
        onPressed: isAPILoading
            ? () {}
            : () async {
                isAPILoading = true;
                if (mounted) setState(() {});
                updateCustomizeProfile();

                isAPILoading = false;
                if (mounted) setState(() {});
              },
      ),
    );
  }
}
