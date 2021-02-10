import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<StateEntry>> fetchData() async {
  final response =
      await http.get('https://rki-vaccination-data.vercel.app/api');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return parseResponse(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load vaccination data');
  }
}

class VaccineStatus {
  const VaccineStatus(
      {this.total,
      this.vaccinated,
      this.difference_to_the_previous_day,
      this.quote});
  final int total;
  final int vaccinated;
  final int difference_to_the_previous_day;
  final double quote;

  factory VaccineStatus.fromJson(Map<String, dynamic> json) {
    return VaccineStatus(
      total: json['total'],
      vaccinated: json['vaccinated'],
      difference_to_the_previous_day: json['difference_to_the_previous_day'],
      quote: json['quote'],
    );
  }
}

class StateEntry {
  StateEntry({this.status, this.name});
  final VaccineStatus status;
  final String name;
}

List<StateEntry> parseResponse(String jsonStr) {
  final json = jsonDecode(jsonStr);
  final statesMap = json["states"] as Map<String, dynamic>;
  return statesMap.keys.map((key) {
    final vaccineStatusJson = statesMap[key];
    return StateEntry(
      status: VaccineStatus.fromJson(vaccineStatusJson),
      name: key,
    );
  }).toList();
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Vaccination Progress in Germany'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var sortingType = SortingType.byName;

  int get currentIndex => SortingType.values.indexOf(sortingType);

  void _onSortingSelected(int index) {
    setState(() {
      sortingType = SortingType.values[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final isLandscape = data.size.width > data.size.height;
    final isPortrait = !isLandscape;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          // navigation rail
          if (isLandscape)
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: _onSortingSelected,
              labelType: NavigationRailLabelType.selected,
              destinations: railItems,
            ),
          if (isLandscape) VerticalDivider(thickness: 1, width: 1),
          // app content
          Expanded(
            child: FutureBuilder<List<StateEntry>>(
                future: fetchData(),
                builder: (context, snapshot) {
                  // an error occured
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'An error occured ${snapshot.error}',
                          ),
                        ],
                      ),
                    );
                  }

                  // there's no data yet
                  if (!snapshot.hasData) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Text(
                            'Loading',
                          ),
                        ],
                      ),
                    );
                  }

                  // we have data
                  final items = snapshot.data.sortedBy(sortingType);
                  return ListView.builder(
                    itemBuilder: (context, index) =>
                        StateEntryWidget(entry: items[index]),
                    itemCount: items.length,
                  );
                }),
          ),
        ],
      ),
      bottomNavigationBar: isPortrait
          ? BottomNavigationBar(
              items: barItems,
              currentIndex: currentIndex,
              onTap: _onSortingSelected,
            )
          : null,
    );
  }
}

final barItems = SortingType.values
    .map((it) => BottomNavigationBarItem(
          icon: Icon(it.iconData),
          label: it.tooltip,
        ))
    .toList();

final railItems = SortingType.values
    .map((it) => NavigationRailDestination(
          icon: Icon(it.iconData),
          // FIXME :copy is too long
          //label: Text(it.tooltip),
          label: Text(""),
        ))
    .toList();

class StateEntryWidget extends StatelessWidget {
  final StateEntry entry;

  const StateEntryWidget({Key key, this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecondRoute(
              entry: entry,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Text(
                      "${entry.status.vaccinated} out of ${entry.status.total} vaccinted"),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${entry.status.quote}%",
              style: Theme.of(context).textTheme.headline4,
            ),
          )
        ],
      ),
    );
  }
}

extension StateEntrySortingExtensions on List<StateEntry> {
  List<StateEntry> sortedByQuotaDesc() {
    final output = List<StateEntry>.from(this);
    output.sort((a, b) => b.status.quote.compareTo(a.status.quote));
    return output;
  }

  List<StateEntry> sortedByVaccinatedDesc() {
    final output = List<StateEntry>.from(this);
    output.sort((a, b) => b.status.vaccinated.compareTo(a.status.vaccinated));
    return output;
  }

  List<StateEntry> sortedByNameAsc() {
    final output = List<StateEntry>.from(this);
    output.sort((a, b) => a.name.compareTo(b.name));
    return output;
  }

  List<StateEntry> sortedBy(SortingType sortingType) {
    switch (sortingType) {
      case SortingType.byQuota:
        return sortedByQuotaDesc();
      case SortingType.byVaccinated:
        return sortedByVaccinatedDesc();
      case SortingType.byName:
        return sortedByNameAsc();
    }
  }
}

enum SortingType { byQuota, byVaccinated, byName }

extension SortingTypeExt on SortingType {
  IconData get iconData {
    switch (this) {
      case SortingType.byQuota:
        return Icons.trending_up;
      case SortingType.byVaccinated:
        return Icons.family_restroom;
      case SortingType.byName:
        return Icons.sort_by_alpha;
    }
  }

  String get tooltip {
    switch (this) {
      case SortingType.byQuota:
        return "Sort by Percentage";
      case SortingType.byVaccinated:
        return "Sort by Vaccinated Count";
      case SortingType.byName:
        return "Sort by Name";
    }
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({Key key, this.entry}) : super(key: key);
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

const coatOfArms = <String, String>{
  "Baden-Württemberg":
      "https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Coat_of_arms_of_Baden-W%C3%BCrttemberg_%28lesser%29.svg/200px-Coat_of_arms_of_Baden-W%C3%BCrttemberg_%28lesser%29.svg.png",
  "Bayern":
      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Bayern_Wappen.svg/200px-Bayern_Wappen.svg.png"
};
