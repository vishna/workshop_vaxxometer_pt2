import 'package:flutter/material.dart';
import 'package:vaxxometer/models/state_entry.dart';

class StateDetailScreen extends StatelessWidget {
  const StateDetailScreen({Key key, this.entry}) : super(key: key);
  final StateEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.name),
      ),
      body: Placeholder(),
    );
  }
}
