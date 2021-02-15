import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vaxxometer/misc/coat_of_arms.dart';
import 'package:vaxxometer/misc/design.dart';
import 'package:vaxxometer/models/state_entry.dart';
import 'package:vaxxometer/models/vaccine_status.dart';
import 'package:vaxxometer/widgets/donut_auto_label_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            V_SPACING_8DP,
            Hero(
              tag: entry.name,
              child: CachedNetworkImage(
                height: 200.0,
                width: 200.0,
                imageUrl: imageUrl,
              ),
            ),
            V_SPACING_8DP,
            SizedBox(
              width: 450.0,
              height: 450.0,
              child: Center(
                  child: DonutAutoLabelChart(
                _createSampleData(entry.status.manufacturers),
                animate: true,
              )),
            ),
            V_SPACING_8DP,
          ],
        ),
      ),
    );
  }
}

List<charts.Series<VaccineManufacturer, int>> _createSampleData(
    List<VaccineManufacturer> data) {
  return [
    new charts.Series<VaccineManufacturer, int>(
      id: 'Vaccinations',
      domainFn: (VaccineManufacturer m, _) => m.amount,
      measureFn: (VaccineManufacturer m, _) => m.amount,
      data: data,
      // Set a label accessor to control the text of the arc label.
      labelAccessorFn: (VaccineManufacturer m, _) => "${m.name} (${m.amount})",
    )
  ];
}
