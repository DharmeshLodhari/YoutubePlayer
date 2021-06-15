import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class SelectCableProvider extends StatefulWidget {
  @override
  _SelectCableProviderState createState() => _SelectCableProviderState();
}

class _SelectCableProviderState extends State<SelectCableProvider> {
  List<Map<String, dynamic>> cableProviders = [
    {"image": "assets/images/utility/dstv.png", "name": "DStv Subscription"},
    {"image": "assets/images/utility/gotv.png", "name": "GOtv Subscription"},
    {
      "image": "assets/images/utility/starttimes.png",
      "name": "Startimes Payment"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 16,
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: selectProviderText()),
          SizedBox(
            height: 16,
          ),
          Expanded(
              child: Container(
            child: getListOfProvider(),
          ))
        ],
      ),
    );
  }

  Widget getListOfProvider() {
    return ListView.builder(
      itemBuilder: (context, index) =>
          cableProviderTile(item: cableProviders[index]),
      itemCount: cableProviders.length,
    );
  }

  Widget cableProviderTile({Map<String, dynamic> item}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed("/select-plan-for-cable", arguments: {"provider": item});
      },
      child: Row(
        children: [
          Image.asset(
            item['image'],
            fit: BoxFit.fill,
            height: 80,
            width: 80,
          ),
          SizedBox(
            width: 8,
          ),
          Text(
            item['name'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget selectProviderText() {
    return Text(
      "Select a provider",
      style:
          TextStyle(color: darkGrey, fontSize: 14, fontWeight: FontWeight.w400),
    );
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      title: Text(
        "Cable",
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
