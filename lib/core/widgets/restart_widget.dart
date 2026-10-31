import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  static _RestartWidgetState? _instance;

  static void restart() {
    _instance?.restartApp();
  }

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    RestartWidget._instance = this;
  }

  @override
  void dispose() {
    if (RestartWidget._instance == this) {
      RestartWidget._instance = null;
    }
    super.dispose();
  }

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
