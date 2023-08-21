import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../locale/app_localization.dart';
import '../../../../widget/customized_textform_field.dart';
import '../models/custom_profile_model.dart';
import '../user_auth.dart';

class CustomizeProfileScreen extends StatefulWidget {

  const CustomizeProfileScreen({Key? key}) : super(key: key);

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
  CustomProfileModel customProfileModel = CustomProfileModel();
  // Create a new map to store boolean values
  Map<String, bool> boolMap = {};
  var orderedKeys = <String>[];
  String productLabel = "";
  String serviceLabel = "";
  final TextEditingController productLabelController = TextEditingController();
  final TextEditingController serviceLabelController = TextEditingController();
  Map<String, bool> reorderedBoolMap = {};


  @protected
  void initState() {

    isLoading = true;
    getCustomizeProfile();

    super.initState();
  }


  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      key: _scaffoldGeneralSettingKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
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

    List<MapEntry<String, bool>> entries = reorderedBoolMap.entries.toList();
    bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                String key = entries[index].key;
                bool value = entries[index].value;

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
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
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
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        "Customise Profile",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        if(saveRequired)...[
          Row(
            children: [
              saveBtn(),
              const SizedBox(width: 20.0),
            ],
          ),

        ],

      ],
    );
  }

  Widget getTile({
    required String titleText,
    required bool switchValue,
    required Function(bool) onTapCallback,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
          trailing: Container(
            width: 80,
            child: Switch(
              value: switchValue, // Set the Switch value based on the boolean parameter
              onChanged: onTapCallback, // Use the passed onTap function
              activeTrackColor: navyBlueLight,
              activeColor: navyBlue,
              inactiveTrackColor: darkGrey,
            ),
          ),
          onTap: () {
            // Handle the onTap behavior here, if needed
            if (onTapCallback != null) {
              onTapCallback(!switchValue); // You can also toggle the boolean value
            }
          },
        ),
      ),
    );
  }




  Widget addProductLabelField() {
    return CustomizedTextFormField(
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
    );
  }

  Widget addServiceLabelField() {
    return CustomizedTextFormField(
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
    );
  }

  Future<void> getCustomizeProfile() async {
    Map<String, dynamic>? result = await _auth.customizeProfile();

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
    var remainingKeys = boolMap.keys.where((key) => !orderedKeys.contains(key)).toList();

    // Add the remaining keys to orderedKeys to ensure they are at the end
    orderedKeys.addAll(remainingKeys);

    // Create a new map with the ordered keys
    reorderedBoolMap = Map.fromEntries(orderedKeys.map((key) => MapEntry(key, boolMap[key]!)));

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

    if (_formKey.currentState!.validate()) {

      isLoading = true;
      if (mounted) setState(() {});

      Map<String, bool> currentArrangement = getCurrentBoolArrangement();
      List<String> orderingList = currentArrangement.keys.where((key) => key != 'reviews' && key != 'opening_hours').toList();

      Map<String, dynamic> result = {
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
        if(value == true){

          saveRequired = false;
          showToast(message: "Profile Customization Updated");
          return true;
        }else{
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
    return GestureDetector(
      onTap: updateCustomizeProfile,
      child: Center(
        child: Text(
          "Save",
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

}
