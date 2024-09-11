import 'package:Slydo/screens/blog/user_post/user_post_auth.dart';
import 'package:Slydo/screens/moments/models/attachment_item_model.dart';
import 'package:Slydo/screens/moments/screens/preview_moment_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/state_notifier.dart';
import '../../../locale/app_localization.dart';
import '../../../utils/util.dart';
import '../../../widget/loading_indicator.dart';
import '../../../widget/no_item_in_list.dart';
import '../../more_apps/shopping/models/store.dart';
import '../../more_apps/shopping/shopping_auth.dart';

class PickAttachmentScreen extends StatefulWidget {
  final AttachmentType attachmentType;
  const PickAttachmentScreen({super.key, required this.attachmentType});

  @override
  State<PickAttachmentScreen> createState() => _PickAttachmentScreenState();
}

class _PickAttachmentScreenState extends State<PickAttachmentScreen> {
  String? next = '';
  late UserBloc userBloc;
  bool noItemInList = false;
  bool attachmentLoading = false;
  List<DisplayCardModel> displayCardModelList = [];
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    userBloc = Provider.of<UserBloc>(context, listen: false);

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          scrollController.position.pixels != 0) {
        if (next != null) {
          getAttachmentFromAPI();
        }
      }
    });

    getAttachmentFromAPI();
  }

  void getAttachmentFunction() {
    switch (widget.attachmentType) {
      case AttachmentType.Product:
        getAttachmentFromAPI();
        break;
      case AttachmentType.Service:
        getAttachmentFromAPI();
        break;
      case AttachmentType.Blog:
        getAttachmentFromAPI();
        break;
    }
  }

  Future<Map<String, dynamic>?> getAttachmentAPI() {
    switch (widget.attachmentType) {
      case AttachmentType.Product:
        return ShoppingAuthService().listOfProduct(next, "", "", false,
            userName: userBloc.user.userName);

      case AttachmentType.Service:
        return ShoppingAuthService()
            .listServicesByProvider(next, "", userName: userBloc.user.userName);

      case AttachmentType.Blog:
        return UserPostAuth().listUserPosts(
            next: next, userName: userBloc.user.userName, pageSize: '8');
      default:
        return UserPostAuth().listUserPosts(
            next: next, userName: userBloc.user.userName, pageSize: '8');
    }
  }

  Future<void> getAttachmentFromAPI() async {
    if (mounted) {
      setState(() {
        attachmentLoading = true;
      });
    }
    final Map<String, dynamic>? result = await getAttachmentAPI();

    if (mounted) {
      setState(() {
        attachmentLoading = false;
      });
    }
    // debugPrint('RESULT ::: $result');
    if (result != null) {
      next = result['next'];
      if (result['results'].isEmpty) {
        noItemInList = true;
      } else {
        getDisplayCardModelList(result);
      }
    } else {
      if (mounted) {
        setState(() {
          attachmentLoading = false;
        });
      }
    }
  }

  void getDisplayCardModelList(Map<String, dynamic> result) {
    switch (widget.attachmentType) {
      case AttachmentType.Product:
        {
          final List<Product> resultList = result['results'];
          displayCardModelList = resultList
              .map((e) => DisplayCardModel(
                  id: e.id!,
                  title: e.name ?? "",
                  imageUrl: e.sellerAvatar!,
                  description: e.description ?? ""))
              .toList();
          break;
        }
      case AttachmentType.Service:
        {
          final List<Service> resultList = result['results'];
          displayCardModelList = resultList
              .map((e) => DisplayCardModel(
                  id: e.id!,
                  title: e.name ?? "",
                  imageUrl: e.providerAvatar!,
                  description: e.description ?? ""))
              .toList();
          break;
        }
      case AttachmentType.Blog:
        {
          final List<dynamic> resultList = result['results'];

          for (var e in resultList) {
            displayCardModelList.add(
              DisplayCardModel(
                  id: e['id'],
                  title: e['title'],
                  imageUrl: e['image'],
                  description: e['tag_line']),
            );
          }

          break;
        }
    }
  }

  AppBar appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
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
        'Select a ${widget.attachmentType.name}',
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.emptyList,
          )
        : attachmentLoading && displayCardModelList.isEmpty
            ? buildLoadingIndicator(isLoading: attachmentLoading)
            : ListView.builder(
                controller: scrollController,
                itemCount: displayCardModelList.length + 1,
                itemBuilder: (context, index) {
                  if (index == displayCardModelList.length) {
                    return buildJumpingLoadingIndicator(
                        isLoading: attachmentLoading);
                  }
                  return displayCard(
                      displayCardModel: displayCardModelList[index]);
                },
              );
  }

  Widget displayCard({required DisplayCardModel displayCardModel}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  dense: true,
                  leading: getLeading(displayCardModel.imageUrl),
                  title: Text(
                    messageDecoderWithEmoji(displayCardModel.title)!,
                    maxLines: 1,
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  subtitle: Text(
                    messageDecoderWithEmoji(displayCardModel.description)!,
                    maxLines: 1,
                    style: TextStyle(color: darkGrey, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      AttachmentItemModel(
                          id: displayCardModel.id,
                          title: displayCardModel.title),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLeading(String imageUrl) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 48,
        errorWidget: imageErrorWidget,
        width: 48,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => CircularLoadingIndicator(),
      ),
    );
  }
}

class DisplayCardModel {
  String id;
  String title;
  String imageUrl;
  String description;

  DisplayCardModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
  });
}
