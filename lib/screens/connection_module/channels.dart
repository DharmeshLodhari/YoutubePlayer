import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Channels extends StatefulWidget {
  @override
  State<Channels> createState() => _ChannelsState();
}

class _ChannelsState extends State<Channels> {

  @override
  void initState() {
    super.initState();

    loadAllChannels();

  }

  Future<void> loadAllChannels() async {
    await MessageAuth().fetchChannels();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        SizedBox(width: 20,),
        ...List.generate(
            10, (index) => Padding(
              padding: const EdgeInsets.all(3.0),
              child: channelViewList(),
            )
        )
      ],),
    );
  }

  Widget channelViewList(){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        padding: EdgeInsets.all(18),
        child: Row(children: [
          Container(
            height: 50,
              width: 50,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(36)),
              child: Icon(Icons.group, color: navyBlueLight,),
          ),
          SizedBox(width: 20,),
          Column(children: [
            Text(
              'Group name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10,),
            Text(
              '50 members',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],),
          Expanded(child: SizedBox(width: 20,)),
          Text(
            'Join',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 10,)
        ],),
      ),
    );
  }
}