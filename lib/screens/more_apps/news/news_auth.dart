import 'package:Slydo/screens/more_apps/news/models/NewsDetailItem.dart';
import 'package:Slydo/screens/more_apps/news/models/SubscriptionItem.dart';
import 'package:Slydo/services/auth.dart';

import 'models/NewsListItem.dart';

class NewsAuthService extends AuthService {
  List<Map<String, String>> newsList = [
    {
      "title": "Nigerian army warns 'trouble makers' amid protests",
      "image":
          "https://ichef.bbci.co.uk/live-experience/cps/624/cpsprodpb/vivo/live/images/2020/10/15/18c0f573-6b37-43aa-bfba-6b1f3b5a9a0f.jpg",
      "description":
          "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
    },
    {
      "title":
          "End Sars: How Nigeria's anti-police brutality protests went global",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/14978/production/_114944348_endsarshi063751597.jpg",
      "description":
          "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
    },
    {
      "title":
          "End Sars protests: Osun governor escapes 'assassination attempt'",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/9CEF/production/_114957104_sars.jpg",
      "description":
          "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
    },
    {
      "title":
          "End Sars: How Nigeria's anti-police brutality protests went global",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/14978/production/_114944348_endsarshi063751597.jpg",
      "description":
          "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
    },
    {
      "title":
          "End Sars protests: Osun governor escapes 'assassination attempt'",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/9CEF/production/_114957104_sars.jpg",
      "description":
          "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
    },
    {
      "title": "End Sars: Hated Nigerian police unit's founder 'feels guilty'",
      "image":
          "https://ichef.bbci.co.uk/news/800/cpsprodpb/762D/production/_114935203_sarsfounder-1_moment.jpg",
      "description":
          "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
    },
    {
      "title": "Nigeria state imposes curfew amid jailbreak",
      "image":
          "https://ichef.bbci.co.uk/live-experience/cps/624/cpsprodpb/vivo/live/images/2020/10/19/b77112bd-285c-45c2-8293-c3ceafef3577.png",
      "description":
          "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
    },
    {
      "title": "Nigerian army warns 'trouble makers' amid protests",
      "image":
          "https://ichef.bbci.co.uk/live-experience/cps/624/cpsprodpb/vivo/live/images/2020/10/15/18c0f573-6b37-43aa-bfba-6b1f3b5a9a0f.jpg",
      "description":
          "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
    },
  ];
  Future<List<NewsListItem>> getNewsList() async {
    final newsListItems = newsList
        .map(
          (news) => NewsListItem.fromJson({
            "title": news["title"],
            "image": news["image"],
            "description": news["description"]
          }),
        )
        .toList();
    await Future.delayed(const Duration(seconds: 1));
    return newsListItems;
  }

  Future<List<SubscriptionItem>> getSubscriptionList() async {
    final subscriptionItemList = List.generate(
        10,
        (index) => SubscriptionItem.fromJson({
              "id": 1,
              "image":
                  "https://cdn.punchng.com/wp-content/uploads/2020/08/18131509/punch-logo-500x179-1.png",
              "name": "Punch"
            }));

    await Future.delayed(const Duration(seconds: 1));
    return subscriptionItemList;
  }

  Future<NewsDetailItem> getNewsDetail() async {
    final dummyData = {
      "title":
          "End SARS: See how Nigeria anti-police brutality protests go global",
      "poster":
          "https://cms.qz.com/wp-content/uploads/2018/06/RTR44FE-e1529169440642.jpg?quality=75&strip=all&w=800&h=600",
      "image":
          "https://slydo-assets.s3.amazonaws.com/media/post_image/image_cropper_1646052100803.jpg",
      "video":
          "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/a1f539f00f21c4cb3ac1cb76269f6a36ff6922d7/y2mate.com - Nigerians protesting anti-police brutality bring Lagos to standstill_480p.mp4?raw=true",
      "read": 5,
      "author": "Blogger",
      "author_avatar": "https://i.imgur.com/cVDadwb.png",
      "upload_time": "June 01",
      "short_description":
          "Customer Support is undergoing massive, irreversible change right now – find out how to stay ahead of the curve by adopting the Conversational Support Funnel...",
      "description":
          "With a Slydo account, you can receive and make payment across Africa. Its operation is fast, secure and seamless. Your account comes with a unique QR, which you can send to other users to receive money from them. If you want to send money instead, you can scan the QR of the recipient and make an instant transfer.Safe and Secure Your Slydo account is very safe and secure. You have to set a 6-digit password for access to the app. You also have to set a 4-digit PIN to enable payment from your account. Your account balance is also protected with the same PIN. You have no need to worry about your data security. We encrypt your data at rest and in transit with end to end encryption for your protection",
      "sub_header": "Zero Transaction Fee",
      "tags": [
        "Slydo",
        "Business",
        "Online store",
        "E-commerce",
        "Cashless",
      ],
      "news_list_items": [
        {
          "title": "Nigerian army warns 'trouble makers' amid protests",
          "image":
              "https://ichef.bbci.co.uk/live-experience/cps/624/cpsprodpb/vivo/live/images/2020/10/15/18c0f573-6b37-43aa-bfba-6b1f3b5a9a0f.jpg",
          "description":
              "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
        },
        {
          "title":
              "End Sars: How Nigeria's anti-police brutality protests went global",
          "image":
              "https://ichef.bbci.co.uk/news/800/cpsprodpb/14978/production/_114944348_endsarshi063751597.jpg",
          "description":
              "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
        },
        {
          "title":
              "End Sars protests: Osun governor escapes 'assassination attempt'",
          "image":
              "https://ichef.bbci.co.uk/news/800/cpsprodpb/9CEF/production/_114957104_sars.jpg",
          "description":
              "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
        },
        {
          "title":
              "End Sars: How Nigeria's anti-police brutality protests went global",
          "image":
              "https://ichef.bbci.co.uk/news/800/cpsprodpb/14978/production/_114944348_endsarshi063751597.jpg",
          "description":
              "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
        },
        {
          "title":
              "End Sars protests: Osun governor escapes 'assassination attempt'",
          "image":
              "https://ichef.bbci.co.uk/news/800/cpsprodpb/9CEF/production/_114957104_sars.jpg",
          "description":
              "Humankind is now facing a global crisis. Perhaps the biggest crisis of our generation..."
        }
      ]
    };

    final NewsDetailItem news = NewsDetailItem.fromJson(dummyData);
    await Future.delayed(const Duration(seconds: 1));
    return news;
  }

  Future<void> addToWishList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }
}
