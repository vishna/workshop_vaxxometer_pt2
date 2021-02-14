import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/vaccine_status.dart';
import 'indicator.dart';

const _colors = [
  Colors.amber,
  Colors.tealAccent,
  Colors.blue,
  Colors.redAccent,
  Colors.green,
  Colors.cyan,
  Colors.brown,
  Colors.indigo,
  Colors.pinkAccent,
  Colors.deepPurple
];

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({Key key, this.manufactureres}) : super(key: key);
  final List<VaccineManufacturer> manufactureres;

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            const SizedBox(
              height: 18,
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                      pieTouchData:
                          PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse.touchInput is FlLongPressEnd ||
                              pieTouchResponse.touchInput is FlPanEnd) {
                            touchedIndex = -1;
                          } else {
                            touchedIndex = pieTouchResponse.touchedSectionIndex;
                          }
                        });
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections()),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (int i = 0; i < widget.manufactureres.length; i++) ...[
                  Indicator(
                    color: _colors[i],
                    text: widget.manufactureres[i].name,
                    isSquare: true,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                ],
                SizedBox(
                  height: 18,
                ),
              ],
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    /// https://stackoverflow.com/a/13611678
    final int totalAmount = widget.manufactureres
        .fold(0, (previous, current) => previous + current.amount);

    return widget.manufactureres.mapIndexed((manufacturer, index) {
      final isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;
      final percentValue =
          100.0 * manufacturer.amount.toDouble() / totalAmount.toDouble();
      var title = manufacturer.amount.toString();
      return PieChartSectionData(
        color: _colors[index],
        value: percentValue,
        title: title,
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black),
      );
    }).toList();
  }
}

extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndexed<T>(T f(E e, int i)) {
    var i = 0;
    return this.map((e) => f(e, i++));
  }
}
