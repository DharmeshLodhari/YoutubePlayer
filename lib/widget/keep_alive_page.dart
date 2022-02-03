import 'package:flutter/material.dart';

class KeepAlivePage extends StatefulWidget {
  KeepAlivePage({Key? key, required this.child, this.wantKeepAlive = true})
      : super(key: key);

  final Widget child;
  final bool wantKeepAlive;

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    /// Dont't forget this
    super.build(context);

    return widget.child;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => widget.wantKeepAlive;
}
