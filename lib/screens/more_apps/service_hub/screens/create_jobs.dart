import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/service_hub/auth/service_hub_auth.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/create_job_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/list_of_categories.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_checkbox_field.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../models/job_location_model.dart';

// import '../shopping_auth.dart';

class JobsCreateJobs extends StatefulWidget {
  @override
  _JobsCreateJobsState createState() => _JobsCreateJobsState();
}

class _JobsCreateJobsState extends State<JobsCreateJobs> {
  // final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc? userBloc;

  CategoryListData? pressedCategory;
  CategoryListData? selectedProductCategory;
  CategoryListData? selectedProductCondition;
  String? selectedCategory;
  String? displayCategory;

  final GlobalKey<ScaffoldMessengerState> _jobScaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  int imageCount = 5;
  ScrollController _scrollController = ScrollController();
  List<PickedFile> jobImages = [];
  String jobTitle = "";
  String jobDescription = "";
  String budget = "";
  String locationState = "select state";
  String? locationSelected;

  String productDescription = "";
  String productShortDescription = "";
  String productCategory = "";
  String productCondition = "";
  String productPrice = "";
  String productManufacturer = "";
  bool productIsAvailable = false;
  bool productEnableInSuperStore = false;
  DateTime jobAvailableFrom = DateTime.now();
  DateTime jobEndDate = DateTime.now();
  List productCategories = [
    'PhotoGraphy',
    'baby care',
    'Plumber',
    'Doctor',
  ];
  List? productCategoriesCopy = [
    'PhotoGraphy',
    'baby care',
    'Plumber',
    'Doctor',
  ]; //To hold the full product category at all times.
  bool isLoading = false;
  bool isAPILoading = false;
  String groupValue = "Fixed";
  String taskValue = "Budget";
  String timingValue = "Fixed";
  String taskMethod = "Online";

  bool isSelected = false;
  String? selected;
  // String? selectedCategory;
  bool isCategoryLoading = false;
  String? categoryNext = "";
  String? categoryPrevious = "";
  bool noCatinList = false;
  int? categoryCount = 0;

  bool isLocationLoading = false;
  bool noLocinList = false;
  int? locationCount = 0;
  String? locationNext = "";
  String? locationPrevious = "";
  List<LocationData?> locationsList = [];
  List<LocationData?> locationsListCopy = [];

  List<CategoryListData?> categoriesList = [];

  List<CategoryListData?> categoriesListCopy = [];
  List<String> categoriesNameList = [];
  ScrollController _categoryScrollController = ScrollController();
  ScrollController _locationScrollController = ScrollController();

  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
  ];
  List<String> selectedItems = [];

  void getCategoriesList() async {
    if (!isCategoryLoading) {
      if (categoryNext != null && !isCategoryLoading) {
        isCategoryLoading = true;
        if (mounted) setState(() {});

        var result = await ServiceHubAuthService()
            .getListOfCategories(categoryNext, categoryPrevious);

        if (result == null) {
          noCatinList = true;

          isCategoryLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }
        categoryCount = result.count;
        categoryNext = result.next;
        categoryPrevious = result.previous;
        var tempList = result.results;
        if (mounted) {
          setState(() {
            noCatinList = false;
            isCategoryLoading = false;
            categoriesList.addAll(tempList!);
            categoriesListCopy = categoriesList;
            tempList.forEach((element) {
              categoriesNameList.add(element.name!);
            });
          });
        }
      }
      if (categoriesList.isEmpty) {
        if (mounted) {
          setState(() {
            noCatinList = true;
          });
        }
      } else if (categoryNext == null && categoriesList.length > 6) {
        _jobScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: const Duration(milliseconds: 500),
        ));
      }
    }
  }

  @override
  void deactivate() {
    CacheManager().deleteCache();
    super.deactivate();
  }

  @override
  void initState() {
    getCategoriesList();
    getLocationList();
    _categoryScrollController.addListener(() {
      if (_categoryScrollController.position.pixels ==
              _categoryScrollController.position.maxScrollExtent &&
          _categoryScrollController.position.pixels != 0) {
        getCategoriesList();
      }
    });
    _locationScrollController.addListener(() {
      if (_locationScrollController.position.pixels ==
              _locationScrollController.position.maxScrollExtent &&
          _locationScrollController.position.pixels != 0) {
        getLocationList();
      }
    });

    super.initState();
  }
  
  
  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: ScaffoldMessenger(
        key: _jobScaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          appBar: appBar() as PreferredSizeWidget?,
          body: scaffoldBody(),
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
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
        "Create Job Request",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () => pickImage(),
            child: SvgPicture.asset('assets/images/cam_pic.svg',
                height: 20, width: 20),
          ),
        )
      ],
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      jobImages.isEmpty ? const SizedBox.shrink() : addImages(),
                      const SizedBox(height: 14),
                      addJobTitleField(),
                      const SizedBox(
                        height: 20,
                      ),
                      addWorkField(),
                      const SizedBox(
                        height: 20,
                      ),
                      getCategoryField(),
                      const SizedBox(
                        height: 20,
                      ),
                      getTimingRadioBtn(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          getPickDateStart(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            dateText: 'Start Date',
                          ),
                          getPickDateEnd(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            dateText: 'End Date',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      getTaskFeeRadioBtn(),
                      const SizedBox(height: 15),
                      getTaskMethodRadioBtn(),
                      const SizedBox(height: 20),
                      getAmountField(),
                      const SizedBox(
                        height: 20,
                      ),
                      getLocationField(),
                      const SizedBox(height: 40),
                      getPreviewButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget getTimingRadioBtn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timing',
          style: TextStyle(
              color: blackFont, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        getTimingRadioRow(),
      ],
    );
  }

  Column getTaskFeeRadioBtn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Fee',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: blackFont),
        ),
        getTaskFeeRadionRow(),
      ],
    );
  }

  Column getTaskMethodRadioBtn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How can this task be done?',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: blackFont),
        ),
        getTaskMethodRow(),
      ],
    );
  }

  Row getTimingRadioRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CustomRadioTile(
            groupVal: timingValue,
            callbackFunction: (value) {
              setState(() {
                timingValue = value.toString();
              });
            },
            value: 'Fixed',
          ),
        ),
        Expanded(
          flex: 1,
          child: CustomRadioTile(
            groupVal: timingValue,
            callbackFunction: (value) {
              setState(() {
                timingValue = value.toString();
              });
            },
            value: 'Flexible',
          ),
        ),
      ],
    );
  }

  Row getTaskFeeRadionRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CustomRadioTile(
            groupVal: taskValue,
            callbackFunction: (value) {
              setState(() {
                taskValue = value.toString();
              });
            },
            value: 'Budget',
          ),
        ),
        Expanded(
          flex: 1,
          child: CustomRadioTile(
            groupVal: taskValue,
            callbackFunction: (value) {
              setState(() {
                taskValue = value.toString();
              });
            },
            value: 'Negotiable',
          ),
        ),
      ],
    );
  }

  Row getTaskMethodRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CustomRadioTile(
            groupVal: taskMethod,
            callbackFunction: (value) {
              setState(() {
                taskMethod = value.toString();
              });
            },
            value: 'Physically',
          ),
        ),
        Expanded(
          flex: 1,
          child: CustomRadioTile(
            groupVal: taskMethod,
            callbackFunction: (value) {
              setState(() {
                taskMethod = value.toString();
              });
            },
            value: 'Online',
          ),
        ),
      ],
    );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget addImages() {

    return Container(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: jobImages.length + 1,
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.only(right: 6),
          child: index == 0
              ? addImageButton()
              : index <= jobImages.length
              ? showImage(index - 1)
              : SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget addImageButton() {
    return CustomBoxShadow(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: boxShadowTwo,
        margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  SlydoAppIcon.add_image,
                  color: darkGrey,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  AppLocalization.of(context)!.addImage,
                  style: TextStyle(color: darkGrey, fontSize: 14),
                ),
              ],
            ),
            onTap: () {
              pickImage();
            },
          ),
        ),
      ),
    );
  }

  void pickImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(AppLocalization.of(context)!.selectTheImageSource),
              actions: <Widget>[
                MaterialButton(
                  child: Text(AppLocalization.of(context)!.camera),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text(AppLocalization.of(context)!.gallery),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      ImagePicker().pickImage(source: imageSource).then((value) async {
        if (value != null) {
          /// for cropping the image
          String? croppedImage = await ImageCrop().cropImage(value.path);
          if (croppedImage == null) {
            return;
          }

          jobImages.add(PickedFile(croppedImage));
          if (mounted) setState(() {});
        }
      });
    }
  }

  Widget showImage(int index) {
    return Container(
      height: 100,
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: dividerColor,
            margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: FileImage(
                      File(jobImages[index].path),
                    ),
                    fit: BoxFit.fill),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              padding: const EdgeInsets.only(right: 6, top: 6),
              alignment: Alignment.topRight,
              icon: Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: iconBtnGrey,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  SlydoAppIcon.remove,
                  color: blackFont,
                  size: 15,
                ),
              ),
              onPressed: () {
                setState(() {
                  jobImages.removeAt(index);
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget addJobTitleField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.jobTitle,
      labelColor: blackFont,
      hintText: 'what\'s the name of the job',
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.jobTitle;
      },
      onChanged: (val) {
        jobTitle = val;
      },
    );
  }

  Widget getLocationField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.location,
      titleColor: blackFont,
      fontWeight: FontWeight.bold,
      child: ListTile(
        dense: true,
        title: Text(
          locationState,
          style: TextStyle(
              color: darkGrey.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          loccationAndroidSheet();
        },
      ),
    );
  }

  Widget getProductShortDescription() {
    return CustomizedTextFormField(
      labelText: "Short description",
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.shortDescription;
      },
      onChanged: (val) {
        productShortDescription = val;
      },
    );
  }

  Widget getProductDescription() {
    return CustomizedTextFormField(
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      labelText: AppLocalization.of(context)!.description,
      onChanged: (val) {
        jobDescription = val;
      },
    );
  }

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: AppLocalization.of(context)!.jobCategoryFit,
      titleColor: blackFont,
      fontWeight: FontWeight.bold,
      child: ListTile(
        dense: true,
        title: Text(
          displayCategory != null ? displayCategory! : "select category",
          style: TextStyle(
              color: darkGrey.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: darkGrey,
        ),
        onTap: () {
          categoryAndroidSheet();
        },
      ),
    );
  }

  void loccationAndroidSheet() {
    locationsList = locationsListCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.50,
            child: Column(
              children: [
                Text(
                  "Choose Location",
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16.8,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  color: darkGrey.withOpacity(.5),
                ),
                Expanded(
                  child: NotificationListener<ScrollEndNotification>(
                    onNotification: (scrollEnd) {
                      final metrics = scrollEnd.metrics;
                      if (metrics.atEdge) {
                        bool isTop = metrics.pixels == 0;
                        if (!isTop) {
                          changeState(() {});
                        }
                      }
                      return true;
                    },
                    child: ListView.builder(
                      controller: _locationScrollController,
                      shrinkWrap: true,
                      itemCount: locationsList.length,
                      itemBuilder: (context, index) {
                        LocationData location = locationsList[index]!;

                        return ListTile(
                          title: Text(
                            "${location.name}",
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                color: blackFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          dense: true,
                          onTap: () {
                            locationSelected = location.slug;
                            locationState = location.name!;
                            Navigator.pop(context);
                            setState(() {});
                            
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void categoryAndroidSheet() {
    categoriesList = categoriesListCopy;
    androidBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, changeState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.50,
            child: Column(
              children: [
                Text(
                  "Select Category",
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 16.8,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  color: darkGrey.withOpacity(.5),
                ),
                Expanded(
                  child: NotificationListener<ScrollEndNotification>(
                    onNotification: (scrollEnd) {
                      final metrics = scrollEnd.metrics;
                      if (metrics.atEdge) {
                        bool isTop = metrics.pixels == 0;
                        if (!isTop) {
                          changeState(() {});
                        }
                      }
                      return true;
                    },
                    child: ListView.builder(
                      controller: _categoryScrollController,
                      shrinkWrap: true,
                      itemCount: categoriesList.length,
                      itemBuilder: (context, index) {
                        CategoryListData category = categoriesList[index]!;
                        return ListTile(
                          title: Text(
                            "${category.name}",
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                color: blackFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          dense: true,
                          onTap: () {
                            selectedCategory = category.slug;
                            displayCategory = category.name;
                            Navigator.pop(context);
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void selectItemCategory() async {
    final pressedCategory = await showDialog<ProductCategory>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                      child: Column(
                        children: productCategories?.map<Widget>((category) {
                              if (selectedProductCategory == category) {
                                return Container(
                                  color: selectedListItemBackgroundBlue,
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      category.name,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    trailing: Icon(
                                      SlydoAppIcon.checked,
                                      color: navyBlue,
                                      size: 12,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, category);
                                    },
                                  ),
                                );
                              }
                              return ListTile(
                                title: Text(
                                  category.name,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                                dense: true,
                                onTap: () {
                                  Navigator.pop(context, category);
                                },
                              );
                            }).toList() ??
                            [],
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCategory != null) {
      selectedProductCategory = pressedCategory as CategoryListData?;
      productCategory = selectedProductCategory!.name!;
      setState(() {});
    }
  }

  // Widget getProductConditionField() {
  //   return CustomizedDropDownField(
  //     title: "Product condition",
  //     child: ListTile(
  //       dense: true,
  //       title: Row(
  //         children: [
  //           Text(
  //             selectedProductCondition != null
  //                 ? selectedProductCondition!.name
  //                 : "",
  //             style: TextStyle(
  //                 color: blackFont, fontSize: 16, fontWeight: FontWeight.w600),
  //           ),
  //           Expanded(
  //             child: Text(
  //               selectedProductCondition != null
  //                   ? " (" + selectedProductCondition!.description + ")"
  //                   : "",
  //               maxLines: 1,
  //               style: TextStyle(
  //                 fontSize: 16,
  //               ),
  //               softWrap: false,
  //               overflow: TextOverflow.fade,
  //             ),
  //           ),
  //         ],
  //       ),
  //       trailing: Icon(
  //         Icons.keyboard_arrow_down,
  //         color: darkGrey,
  //       ),
  //       onTap: () {
  //         selectItemCondition();
  //       },
  //     ),
  //   );
  // }

  void selectItemCondition() async {
    final pressedCondition = await showDialog<ProductCondition>(
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: conditions.map<Widget>((condition) {
                          if (selectedProductCondition == condition) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Row(
                                  children: [
                                    Text(
                                      condition.name,
                                      style: TextStyle(
                                          color: navyBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Expanded(
                                      child: Text(
                                        selectedProductCondition != null
                                            ? " (" +
                                                // selectedProductCondition!.
                                                //  +
                                                ")"
                                            : "",
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 16, color: navyBlue),
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, condition);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Row(
                              children: [
                                Text(
                                  condition.name,
                                  style: TextStyle(
                                      color: blackFont,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                                Expanded(
                                  child: Text(
                                    " (" + condition.description + ")",
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 16, color: blackFont),
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ],
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, condition);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCondition != null) {
      selectedProductCondition = pressedCondition as CategoryListData?;
      productCondition = selectedProductCondition!.name!;
      setState(() {});
    }
  }

  Widget addWorkField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.wantToGetDone,
      hintText: 'What\'s the description of the job',
      labelColor: blackFont,
      maxLines: 3,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context)!.pleaseEnterManufacturerName;
      },
      onChanged: (val) {
        jobDescription = val;
      },
    );
  }

  Widget getAmountField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.yourBudget,
      labelColor: blackFont,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      isAmountField: true,
      onChanged: (val) {
        if (val.isNotEmpty) {
          try {
            budget = double.parse(val.replaceAll(',', '')).toString();
          } catch (e) {
            showToast(message: e.toString());
          }
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.pleaseEnterValidAmout;
      },
    );
  }

  Widget getPreviewButton() {
    return CurvedButton(
      onPressed: isAPILoading
          ? () {}
          : () async {
              FocusScope.of(context).unfocus();
              isAPILoading = true;
              if (mounted) setState(() {});

              await addJob();

              isAPILoading = false;
              if (mounted) setState(() {});
            },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Submit",
      isLoading: isAPILoading,
    );
  }

  bool getIsNegotiable() {
    return taskValue == 'Budget' ? false : true;
  }

  void getLocationList() async {
    if (!isLocationLoading) {
      if (locationNext != null && !isLocationLoading) {
        isLocationLoading = true;
        if (mounted) setState(() {});

        var result = await ServiceHubAuthService()
            .getJobLocation(locationNext, locationPrevious);

        if (result == null) {
          noLocinList = true;

          isLocationLoading = false;
          if (mounted) {
            setState(() {});
          }
          return;
        }

        locationCount = result.count;
        locationNext = result.next;
        locationPrevious = result.previous;
        var tempList = result.results;
        if (mounted) {
          setState(() {
            noLocinList = false;
            isLocationLoading = false;
            locationsList.addAll(tempList!);
            locationsListCopy = locationsList;
            tempList.forEach((element) {
              categoriesNameList.add(element.name!);
            });
          });
        }
      }
      if (locationsList.isEmpty) {
        if (mounted) {
          setState(() {
            noLocinList = true;
          });
        }
      } else if (locationNext == null && locationsList.length > 6) {
        _jobScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Future<void> addJob() async {
    if (_formKey.currentState!.validate()) {
      if (jobImages.length >= 1) {
        if (true) {
          CreateJobModel job = CreateJobModel();
          Pictures pictures = Pictures();
          Category category = Category();
          job.pictures = jobImages
              .map((file) => Pictures(
                  image: File(file.path), caption: '$selectedCategory 1'))
              .toList();
          job.title = jobTitle;
          // job.description = productDescription;
          job.dueDate = DateFormat('yyyy-MM-dd').format(jobEndDate);
          job.category = Category(
              name: selectedCategory,
              slug: selectedCategory!.toLowerCase(),
              image: '');
          job.description = jobDescription;
          job.pay = moneyInputNormalizer(budget);
          job.location = locationSelected;
          job.tags = [selectedCategory!.toLowerCase()];
          // job.availableFrom = jobAvailableFrom;
          // job.enableInSuperStore = productEnableInSuperStore;
          // print('active')

          await ServiceHubAuthService().createJobRequest({
            'title': jobTitle,
            'location': locationSelected,
            'pay': moneyInputNormalizer(budget),
            'description': jobDescription,
            'category': selectedCategory,
            'is_negotiable': getIsNegotiable(),
            'tags': [selectedCategory!.toLowerCase()],
            'due_date': DateFormat('yyyy-MM-dd').format(jobEndDate),
            'caption': selectedCategory,
            'picture_count': jobImages.length,
            'file': '',
            'localImages': jobImages.map((file) => File(file.path)).toList(),
          }).then((value) {
            print(value.toString() + 'My job');
            // job = value
            Navigator.pushNamed(context, Routes.MY_JOB_DETAILS,
                arguments: {'jobId': value!.id, 'listingId': ''});
            showToast(
                message: AppLocalization.of(context)!.jobAddedSuccessfully);
          }).catchError((error) {
            debugPrint(error.toString());
            showToast(message: error.toString());
          });
        }
      } else {
        showToast(message: AppLocalization.of(context)!.pleaseAddImage);
      }
    }
  }

  bool validateDropdown() {
    if (selectedProductCategory != null && selectedProductCondition != null) {
      return true;
    } else {
      showToast(
          message: AppLocalization.of(context)!
              .pleaseSelectProductCategoryAndCondition);
      return false;
    }
  }

  Widget getIsAvailableField() {
    return CustomizedCheckBoxField(
      onTap: () {
        productIsAvailable = !productIsAvailable;
        setState(() {});
      },
      isChecked: productIsAvailable,
      title: "Is product available now?",
    );
  }

  Widget getEnableInSuperStoreField() {
    return CustomizedCheckBoxField(
      onTap: () {
        productEnableInSuperStore = !productEnableInSuperStore;
        setState(() {});
      },
      isChecked: productEnableInSuperStore,
      title: AppLocalization.of(context)!.enableInSuperStore,
    );
  }

  Widget getStartDateField() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          builder: customThemeBuilder,
          context: context,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2101),
        ).then((value) {
          jobAvailableFrom = DateTime(value!.year, value.month, value.day);
          setState(() {});
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "Start Date",
        child: Container(
          child: ListTile(
            dense: true,
            title: Text(
              formatDate(jobAvailableFrom),
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            trailing: Icon(
              SlydoAppIcon.date,
              size: 16,
              color: darkGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget getEndDateField() {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          builder: customThemeBuilder,
          context: context,
          initialDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
          lastDate: DateTime(2101),
        ).then((value) {
          jobEndDate = DateTime(value!.year, value.month, value.day);
          setState(() {});
        }).catchError((error) {});
      },
      child: CustomizedDropDownField(
        title: "End Date",
        child: Container(
          child: ListTile(
            dense: true,
            title: Text(
              formatDate(jobEndDate),
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            trailing: Icon(
              SlydoAppIcon.date,
              size: 16,
              color: darkGrey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getPickDateStart({
    CrossAxisAlignment? crossAxisAlignment,
    String? dateText,
  }) =>
      Column(
        crossAxisAlignment: crossAxisAlignment!,
        children: [
          Text(
            dateText!,
            style: TextStyle(
                color: blackFont, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              showDatePicker(
                builder: customThemeBuilder,
                context: context,
                initialDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                firstDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                lastDate: DateTime(2101),
              ).then((value) {
                jobAvailableFrom =
                    DateTime(value!.year, value.month, value.day);

                setState(() {});
              }).catchError((error) {});
            },
            child: Container(
                width: 160,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: darkGrey.withOpacity(.5))),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkGrey.withOpacity(.3)),
                      child: SvgPicture.asset(
                        'assets/images/Calendar.svg',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      formatDate(jobAvailableFrom),
                    ),
                  ],
                )),
          ),
        ],
      );

  getPickDateEnd({
    CrossAxisAlignment? crossAxisAlignment,
    String? dateText,
  }) =>
      Column(
        crossAxisAlignment: crossAxisAlignment!,
        children: [
          Text(
            dateText!,
            style: TextStyle(
                color: blackFont, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              showDatePicker(
                builder: customThemeBuilder,
                context: context,
                initialDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                firstDate: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
                lastDate: DateTime(2101),
              ).then((value) {
                jobEndDate = DateTime(value!.year, value.month, value.day);

                setState(() {});
              }).catchError((error) {});
            },
            child: Container(
                width: 160,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: darkGrey.withOpacity(.5))),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkGrey.withOpacity(.3)),
                      child: SvgPicture.asset(
                        'assets/images/Calendar.svg',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      formatDate(jobEndDate),
                    ),
                  ],
                )),
          ),
        ],
      );
}

class CustomRadioTile extends StatelessWidget {
  const CustomRadioTile({
    Key? key,
    required this.groupVal,
    required this.value,
    required this.callbackFunction,
  }) : super(key: key);

  final String groupVal;
  final String value;
  final Function(String?) callbackFunction;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RadioListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: const VisualDensity(
          horizontal: VisualDensity.minimumDensity,
          // vertical: VisualDensity.minimumDensity,
        ),
        title: Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        value: value,
        groupValue: groupVal,
        onChanged: callbackFunction,
      ),
    );
  }
}

class CustomizedRadioButtonRow extends StatelessWidget {
  const CustomizedRadioButtonRow({
    Key? key,
    required this.groupValue,
  }) : super(key: key);

  final String groupValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Timing'),
        const SizedBox(
          height: 6,
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                child: Row(
                  children: [
                    Radio(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                      value: "Fixed",
                      groupValue: groupValue,
                      onChanged: (String? value) {
                        // setState(() {
                        //   groupValue = value!;
                        // });
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        // setState(() {
                        //   groupValue = "Fixed";
                        // });
                      },
                      child: const Text(
                        "Fixes",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Row(
                  children: [
                    Radio(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                      value: "Fixed",
                      groupValue: groupValue,
                      onChanged: (String? value) {
                        // setState(() {
                        //   groupValue = value!;
                        // });
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        // setState(() {
                        //   groupValue = "Fixed";
                        // });
                      },
                      child: const Text(
                        "Fixes",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
