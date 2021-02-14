import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vaxxometer/misc/coat_of_arms.dart';
import 'package:vaxxometer/models/state_entry.dart';
import 'package:vaxxometer/widgets/pie_chart_sample2.dart';

class StateDetailScreen extends StatelessWidget {
  const StateDetailScreen({Key key, this.entry}) : super(key: key);
  final StateEntry entry;

  @override
  Widget build(BuildContext context) {
    final imageUrl = coatOfArms[entry.name];
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.name),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: entry.name,
            child: CachedNetworkImage(
              height: 200.0,
              width: 200.0,
              imageUrl: imageUrl,
            ),
          ),
          PieChartSample2(
            manufactureres: entry.status.manufacturers,
          ),
        ],
      ),
    );
  }
}
