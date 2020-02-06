import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsTile extends StatelessWidget {
  SettingsTile({Key key, this.pickImage}) : super(key: key);

  final Function pickImage;

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(
            userBloc.user.fullName,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(userBloc.user.userName),
          leading: Image.network(
            userBloc.user.avatar,
            height: 45,
            width: 45,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 45,
                width: 45,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes
                      : null,
                ),
              );
            },
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.mode_edit,
              color: darkBlue(),
            ),
            onPressed: pickImage,
          ),
        ),
      ),
    );
  }
}
