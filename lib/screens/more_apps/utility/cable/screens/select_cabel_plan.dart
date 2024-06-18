import 'package:Slydo/screens/more_apps/utility/cable/model/cable_plan.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SelectCablePlan extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const SelectCablePlan({super.key, this.arguments});
  @override
  State<SelectCablePlan> createState() => _SelectCablePlanState();
}

class _SelectCablePlanState extends State<SelectCablePlan> {
  List<Map<String, dynamic>> cablePlansJson = [
    {
      "name": "DStv Premium",
      "price": "₦18,400/month",
      "features": [
        "174+ channels",
        "16 sports channels",
        "Movies",
        "Showmax",
        "Music"
      ],
      "packs": [
        {
          "name": "Supersports",
          "image":
              "https://yt3.ggpht.com/ytc/AKedOLT2kdsvOnV-ohrUTkZvlrRaFSupT3Okz_cydVfsQg=s900-c-k-c0x00ffffff-no-rj"
        },
        {
          "name": "Mnet",
          "image":
              "https://pbs.twimg.com/profile_images/1344558909147770881/j84Bscln_400x400.png"
        }
      ],
    },
    {
      "name": "DStv Compact Plus",
      "price": "₦12,400/month",
      "features": [
        "161+ channels",
        "Premier League",
        "NBA",
        "UCL mathches",
        "Movies",
        "UFC",
      ],
      "packs": [
        {
          "name": "Premier League",
          "image":
              "https://obamabcn.com/wp-content/uploads/2019/11/logo-premier-league.jpg"
        },
        {
          "name": "NBA",
          "image":
              "https://seeklogo.com/images/N/nba-tv-logo-585DF08BF0-seeklogo.com.png"
        }
      ],
    },
    {
      "name": "DStv Compact",
      "price": "₦7,900/month",
      "features": [
        "146+ channels",
        "Premier League",
        "WWE",
        "Movies",
        "Kiddies TV"
      ],
      "packs": [
        {
          "name": "WWE",
          "image":
              "https://uploads-sportbusiness.imgix.net/uploads/2020/01/GettyImages-1180515733.jpg?auto=compress,format&crop=faces,entropy,edges&fit=crop&w=1024&h=673"
        },
        {
          "name": "MTV Base",
          "image":
              "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/MTV_BASE_logo.svg/493px-MTV_BASE_logo.svg.png"
        }
      ],
    },
    {
      "name": "DStv Confam",
      "price": "₦4,615/month",
      "features": [
        "108+ channels",
        "La Liga",
        "Documentary",
        "Disney Junior",
        "Music"
      ],
      "packs": [
        {
          "name": "La Liga",
          "image":
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdB1WghrbRm7sSsxMEPLZgXVm6ij7riirdSa-Mim8uRc7K63c9W8f-kTgpKxj1ng3NOg4&usqp=CAU"
        },
        {
          "name": "Natgeo Wild",
          "image":
              "https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/National_Geographic_Wild_logo.svg/1200px-National_Geographic_Wild_logo.svg.png"
        }
      ],
    },
    {
      "name": "DStv Yanga",
      "price": "₦2,565/month",
      "features": [
        "87+ channels",
        "Series A",
        "TV Series",
        "Lifestyle",
        "Music"
      ],
      "packs": [
        {
          "name": "Series A",
          "image":
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRQdZBphWWlpLrpwOYEKcSa-BZmgmpty3-JDg&usqp=CAU"
        },
        {
          "name": "Sound City",
          "image":
              "https://soundcity.tv/wp-content/uploads/soundcity-black-logo.png"
        }
      ],
    },
    {
      "name": "DStv Padi",
      "price": "₦1,850/month",
      "features": [
        "48+ channels",
        "Sports highlights",
        "Africa magic",
        "Cartoons",
        "News"
      ],
      "packs": [
        {
          "name": "Africa Magic",
          "image":
              "https://upload.wikimedia.org/wikipedia/en/a/a7/AfricaMagic-logo.png"
        },
        {
          "name": "Cartoon Network",
          "image":
              "https://banner2.cleanpng.com/20180404/avq/kisspng-cartoon-network-logo-television-animation-cartoon-network-5ac59e4556f2f6.8778586515229005493562.jpg"
        }
      ],
    },
  ];

  List<CablePlan> cablePlans = [];

  @override
  void initState() {
    for (var element in cablePlansJson) {
      cablePlans.add(CablePlan.fromJson(element));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            child: getListOfProvider(),
          ),
        )
      ],
    );
  }

  Widget getListOfProvider() {
    return ListView.builder(
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: cablePlanTile(plan: cablePlans[index]),
      ),
      itemCount: cablePlans.length,
    );
  }

  Widget cablePlanTile({required CablePlan plan}) {
    return GestureDetector(
      onTap: () async {
        final selectedPlan = await Navigator.of(context)
            .pushNamed("/cable-plan-detail", arguments: {"plan": plan});

        if (selectedPlan != null) {
          if (selectedPlan is CablePlan) {
            Navigator.pop(context, selectedPlan);
          }
        }
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: dividerColor,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dividerColor, width: 0.2)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.name!,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: blackFont),
                        ),
                        Row(
                          children: [
                            Text(
                              "₦",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: navyBlue,
                                  fontFamily: "Inter"),
                            ),
                            Text(
                              plan.price!.replaceAll("₦", ""),
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
                      height: 16,
                    ),
                    getPlanFeatures(plan: plan),
                  ],
                ),
              ),
              Divider(
                height: 0,
                color: dividerColor,
                thickness: 1,
              ),
              Container(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: plan.packs![0].image!,
                              fit: BoxFit.fill,
                              width: 32,
                              height: 32,
                              errorWidget: imageErrorWidget,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            plan.packs![0].name!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: plan.packs![1].image!,
                              fit: BoxFit.fill,
                              width: 32,
                              height: 32,
                              errorWidget: imageErrorWidget,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            plan.packs![1].name!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getPlanFeatures({required CablePlan plan}) {
    return Column(children: getColumnChildren(plan: plan));
  }

  List<Widget> getColumnChildren({required CablePlan plan}) {
    final List<Widget> items = [];

    for (int i = 0; i < plan.features!.length; i = i + 2) {
      items.add(
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      plan.features![i],
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: blackFont),
                    )
                  ],
                ),
              ),
              if (i + 1 < plan.features!.length)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        plan.features![i + 1],
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: blackFont),
                      )
                    ],
                  ),
                )
              else
                Expanded(
                  child: Container(),
                ),
            ],
          ),
        ),
      );
    }

    return items;
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      title: Text(
        "Select a plan",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: blackFont),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
