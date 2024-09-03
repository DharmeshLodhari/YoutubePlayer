import 'package:Slydo/screens/moments/screens/moment_detail/moment_comment.screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/widgets/silver_app_bar_delegate.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/tab_selection.dart';
import 'package:flutter/material.dart';

class SocialMedia extends StatefulWidget {
  const SocialMedia({super.key, this.arguments});

  final dynamic arguments;

  @override
  State<SocialMedia> createState() => _SocialMediaState();
}

class _SocialMediaState extends State<SocialMedia>
    with SingleTickerProviderStateMixin {
  String? momentUrl;
  String? yarnUrl;
  int _currentIndex = 0;
  TabController? _tabController;
  PageController? _pageController;

  @override
  void initState() {
    String modelName = widget.arguments["modelName"];
    modelName = modelName.toLowerCase();
    final String id = widget.arguments["id"];

    yarnUrl = "/api/v1/social/ask/$modelName/$id/";
    momentUrl = "/api/v1/social/moments/$modelName/$id/";
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(initialPage: _currentIndex);

    // Add a listener to the tab controller that updates the current index
    _tabController?.addListener(tabControllerListener);
    super.initState();
  }

  void tabControllerListener() {
    _currentIndex = _tabController!.index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController!.hasClients) {
        _pageController?.animateToPage(_currentIndex,
            duration: const Duration(milliseconds: 1), curve: Curves.easeInOut);
      }
    });
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController?.removeListener(tabControllerListener);
    _tabController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, "back pressed");
        return true;
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        body: _buildBody(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      title: Text(
        '${widget.arguments["modelName"]} Showcase',
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTabProduct(),
        ],
      ),
    );
  }

  Widget _buildTabProduct() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _menuBar(context),
            Expanded(
              flex: 1,
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (int i) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    _currentIndex = i;
                  });
                },
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: const Center(
                      child: Text("Moment"),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: const Center(
                      child: Text("Yarn"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: <Widget>[
          getTabUI(
            title: "Moment",
            tabIndex: 0,
            onTap: _onPlaceBidButtonPress,
          ),
          getTabUI(
            title: "Yarn",
            tabIndex: 1,
            onTap: _onBuyNowButtonPress,
          ),
        ],
      ),
    );
  }

  void _onPlaceBidButtonPress() {
    _tabController?.animateTo(0,
        duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onBuyNowButtonPress() {
    _tabController?.animateTo(1,
        duration: const Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  Widget getTabUI(
      {String title = "", @required int? tabIndex, void Function()? onTap}) {
    return Tab(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: _tabController?.index == tabIndex ? 20 : 30,
              vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            shape: BoxShape.rectangle,
            color: _tabController?.index == tabIndex
                ? navyBlue
                : Colors.transparent,
          ),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: _tabController?.index == tabIndex ? white : blackFont,
              fontSize: 14,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
