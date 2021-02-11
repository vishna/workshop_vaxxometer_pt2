import 'package:flutter/material.dart';
import 'package:vaxxometer/misc/api.dart';
import 'package:vaxxometer/models/sorting_type.dart';
import 'package:vaxxometer/models/state_entry.dart';
import 'package:vaxxometer/screens/state_detail_screen.dart';
import 'package:vaxxometer/widgets/state_entry_widget.dart';

class StatesScreen extends StatefulWidget {
  StatesScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StatesScreenState createState() => _StatesScreenState();
}

class _StatesScreenState extends State<StatesScreen> {
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
                  final itemBuilder = (context, index) => StateEntryWidget(
                        entry: items[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StateDetailScreen(
                                entry: items[index],
                              ),
                            ),
                          );
                        },
                      );
                  return LayoutBuilder(builder: (context, constraints) {
                    if (constraints.maxWidth > 800.0) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 800),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 250,
                            ),
                            itemBuilder: itemBuilder,
                            itemCount: items.length,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemBuilder: itemBuilder,
                        itemCount: items.length,
                      );
                    }
                  });
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
