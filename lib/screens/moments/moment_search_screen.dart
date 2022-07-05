// import 'package:Slydo/screens/moments/models/moments_model.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
//
// import '../../utils/colors.dart';
// import '../../utils/navigation_util.dart';
// import '../../utils/util.dart';
// import '../../widget/customized_textform_field.dart';
// import 'moment_detail_page.dart';
// import 'moments_service.dart';
//
// class MomentSearchScreen extends StatefulWidget {
//   const MomentSearchScreen({Key? key}) : super(key: key);
//
//   @override
//   _MomentSearchScreenState createState() => _MomentSearchScreenState();
// }
//
// class _MomentSearchScreenState extends State<MomentSearchScreen> {
//
//   List<SearchMomentModel> searchMomentModelList = [];
//
//   _getMoments(){
//
//   }
//   AppBar appBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       titleSpacing: 0,
//       automaticallyImplyLeading: false,
//       leading: IconButton(
//         icon: Icon(
//           Icons.keyboard_arrow_left,
//           color: navyBlue,
//           size: 24,
//         ),
//         onPressed: () {
//           Navigator.pop(context);
//         },
//       ),
//       title: Text(
//         "Search moment",
//         style: TextStyle(
//           color: blackFont,
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar(),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               CustomizedTextFormField(
//                 hintText: 'Search',
//                 autoFocus: true,
//                 onChanged: (value){
//                   _getMoments(value);
//                 },
//               ),
//
//               GridView.builder(
//                 shrinkWrap: true,
//                 padding: EdgeInsets.zero,
//                 physics: NeverScrollableScrollPhysics(),
//                 gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//                   maxCrossAxisExtent: 200,
//                   mainAxisExtent: 300,
//                 ),
//                 itemCount: searchMomentModelList.length,
//                 itemBuilder: (context, index) {
//                   return ExploreMomentsCard(
//                     index: index,
//                     exploreMomentsModelList: exploreMomentsList,
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class SearchMomentSingleWidget extends StatelessWidget {
//   final SearchMomentModel searchMomentModel;
//   const SearchMomentSingleWidget({Key? key, required this.searchMomentModel}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         MomentsService()
//             .getSingleMoment(momentId: searchMomentModel.id!)
//             .then((momentsModelList) {
//           NavigationUtil.push(
//             context,
//             screen: MomentsDetailsScreen(
//               indexOfMoment: 0,
//               // Wrapping it around a List ([]) because the moment detail screen requires a List<List<MomentModel>>
//               momentsModelList: [momentsModelList],
//             ),
//           );
//         }).catchError((e) {
//           showToast(message: 'ERROR -> $e');
//         });
//       },
//       child: Card(
//         color: Colors.grey,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             _getMediaRenderer(
//                 momentModel: exploreMomentsModelList[index].moments!.first),
//             Align(
//               alignment: Alignment.topLeft,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 4.0),
//                 child: SizedBox(
//                   width: 25,
//                   child: getCircularUserAvatar(
//                       exploreMomentsModelList[index].avatar!),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.bottomLeft,
//               child: Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       truncateString(
//                         str: exploreMomentsModelList[index].ownerName!,
//                         lengthToTruncateAt: 20,
//                       ),
//                       style: TextStyle(
//                         fontSize: 12,
//                         shadows: [
//                           Shadow(
//                             blurRadius: 4.0,
//                             color: blackFont,
//                             offset: Offset(0.0, 0),
//                           ),
//                         ],
//                         color: Colors.white,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     SizedBox(height: 3),
//                   ],
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.topRight,
//               child: momentListLengthWidget(
//                 exploreMomentsModelList[index].moments!.length,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//
//   }
// }
//
// Widget _getMediaRenderer({required SearchMomentModel searchMomentModel}) {
//   if (searchMomentModel.mediaPoster != null) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: CachedNetworkImage(
//         imageUrl: momentModel.mediaPoster!,
//         fit: BoxFit.fill,
//         placeholder: (context, _) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.asset(
//               'assets/images/moment_placeholder_image.png',
//               fit: BoxFit.cover,
//             ),
//           );
//         },
//       ),
//     );
//   }
//   if (momentModel.gif != null) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: CachedNetworkImage(
//         imageUrl: momentModel.gif!,
//         fit: BoxFit.fill,
//       ),
//     );
//   }
//   if (momentModel.mediaType == "image") {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: CachedNetworkImage(
//         imageUrl: momentModel.media!,
//         fit: BoxFit.fill,
//         placeholder: (context, _) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Image.asset(
//               'assets/images/moment_placeholder_image.png',
//               fit: BoxFit.cover,
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   if (momentModel.mediaType == "video") {
//     if (momentModel.mediaPoster == null) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: Image.asset(
//           'assets/images/moment_placeholder_image.png',
//           fit: BoxFit.cover,
//         ),
//       );
//     } else {
//       return Container();
//     }
//   } else {
//     return Container();
//   }
// }
//
//
