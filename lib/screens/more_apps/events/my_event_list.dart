import 'package:Slydo/screens/more_apps/events/event_dashboard_bloc.dart';
import 'package:Slydo/screens/more_apps/events/event_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyEventList extends StatefulWidget {
  @override
  _MyEventListState createState() => _MyEventListState();
}

class _MyEventListState extends State<MyEventList> {
  List<String> imgList = [
    "https://www.telegraph.co.uk/content/dam/Travel/Destinations/Europe/United%20Kingdom/London/london-aerial-thames-guide.jpg",
    "https://www.cityam.com/wp-content/uploads/2020/02/London_Tower_Bridge_City.jpg",
    "https://metab.ern-net.eu/wp-content/uploads/2018/04/London.jpg",
    "https://travel.home.sndimg.com/content/dam/images/travel/fullset/2015/05/28/big-ben-london-england.jpg",
    "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg",
    "https://www.telegraph.co.uk/content/dam/Travel/Destinations/Europe/United%20Kingdom/London/london-aerial-thames-guide.jpg",
    "https://www.cityam.com/wp-content/uploads/2020/02/London_Tower_Bridge_City.jpg",
    "https://metab.ern-net.eu/wp-content/uploads/2018/04/London.jpg",
    "https://travel.home.sndimg.com/content/dam/images/travel/fullset/2015/05/28/big-ben-london-england.jpg",
    "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/20000/20665-London.jpg"
  ];

  EventDashboardBloc _eventDashboardBloc;

  @override
  Widget build(BuildContext context) {
    _eventDashboardBloc = Provider.of<EventDashboardBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        _eventDashboardBloc.index = 0;
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: imgList
                  .map(
                    (element) => Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: EventTile(
                          imageUrl: element,
                        )),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
