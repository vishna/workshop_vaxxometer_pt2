## Vaxxometer Workshop, 12/02/2021

### Carry over work from 1st workshop

In case you've missed the first vaxxometer workshop, check it out here:

https://github.com/vishna/workshop_vaxxometer

Make sure you have appropriate changes in:

- lib/main.dart
- test/widget_test.dart
- pubspec.yaml

The project zip file is here: https://github.com/vishna/workshop_vaxxometer/archive/main.zip

### Adaptive Layout

We want to replace FAB button with something that has better UX. We'll use:

- [Bottom Bar](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html) (for screens with portrait/square ratio)
- [Navigation Rail](https://api.flutter.dev/flutter/material/NavigationRail-class.html) (for screens with landscape ratio)

<img width="200" alt="Screenshot 2021-02-10 at 17 18 38" src="https://user-images.githubusercontent.com/121164/107538286-167d3b00-6bc4-11eb-9011-94da4d0f3298.png"> <img width="400" alt="Screenshot 2021-02-10 at 17 18 44" src="https://user-images.githubusercontent.com/121164/107538307-1bda8580-6bc4-11eb-96bb-b3ce83c1c5e8.png">

#### Adding bottom bar

We start by removing `floatingActionButton` and adding `bottomNavigationBar` instead:

```dart
bottomNavigationBar: BottomNavigationBar(
  items: <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(SortingType.byQuota.iconData),
      label: SortingType.byQuota.tooltip,
    ),
    BottomNavigationBarItem(
      icon: Icon(SortingType.byVaccinated.iconData),
      label: SortingType.byVaccinated.tooltip,
    ),
    BottomNavigationBarItem(
      icon: Icon(SortingType.byName.iconData),
      label: SortingType.byName.tooltip,
    ),
  ],
  currentIndex: SortingType.values.indexOf(sortingType),
  onTap: (index) {
    // TODO implement
  },
)
```

In the onTap we need to convert index to sortingType, so:

```dart
onTap: (index) {
  setState(() {
    sortingType = SortingType.values[index];
  });
}
```

__NOTE__: Remove `_switchSortingType` since it's no longer necessary.

We can extract bottom bar items to a variable called `barItems`:

```dart
final barItems = <BottomNavigationBarItem>[
  BottomNavigationBarItem(
    icon: Icon(SortingType.byQuota.iconData),
    label: SortingType.byQuota.tooltip,
  ),
  BottomNavigationBarItem(
    icon: Icon(SortingType.byVaccinated.iconData),
    label: SortingType.byVaccinated.tooltip,
  ),
  BottomNavigationBarItem(
    icon: Icon(SortingType.byName.iconData),
    label: SortingType.byName.tooltip,
  ),
];
```

and make these simpler using `map` function:

```dart
final barItems = SortingType.values
    .map((it) => BottomNavigationBarItem(
          icon: Icon(it.iconData),
          label: it.tooltip,
        ))
    .toList();
```

#### Adding navigation rail

Follow the example from [the official docs](https://api.flutter.dev/flutter/material/NavigationRail-class.html):

- Refactor our `body:` and wrap it with `Row` (in our case we wrap around `FutureBuilder`)
- Add `NavigationRail` and `VerticalDivider` as shown in docs
- Wrap `FutureBuilder` again but now with `Expanded`

You should end up having something looking similar to this:

```dart
      body: Row(
        children: [
          // navigation rail
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (int index) {
              setState(() {
                // TODO
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: Text('First'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.book),
                label: Text('Second'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star_border),
                selectedIcon: Icon(Icons.star),
                label: Text('Third'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          // app content
          Expanded(
            child: FutureBuilder<List<StateEntry>>(
```

similairly to `BottomBar` we can extract items outside:

```dart
final railItems = SortingType.values
    .map((it) => NavigationRailDestination(
          icon: Icon(it.iconData),
          // FIXME :copy is too long
          //label: Text(it.tooltip),
          label: Text(""),
        ))
    .toList();
```

Wire selected index and tap callback. For the tap callback we have already implemented it for the bottom bar, thus it would be nice to reuse it. We extract callback to its own method:

```dart
void _onSortingSelected(int index) {
  setState(() {
    sortingType = SortingType.values[index];
  });
}
```

...and supply this method as callback for both bottom bar and navigation rail.

```dart
/// ...navigation rail
onDestinationSelected: _onSortingSelected

/// ...bottom bar
onTap: _onSortingSelected,
```

We can also reuse selected index, let's define getter property on our state class:

```dart
int get currentIndex => SortingType.values.indexOf(sortingType);
```

Then we can use this value in our navigation bars:

```dart
/// ...navigation rail
selectedIndex: currentIndex,

/// ...bottom bar
currentIndex: currentIndex,
```

#### Adaptive navigation rail/bottom bar

We need to switch between navigation rail/bottom bar based on screen ratio, for this we'll use `MediaQuery.of` (see [responsive layout](https://flutter.dev/docs/development/ui/layout/responsive) for more information)

```dart
final data = MediaQuery.of(context);
final isLandscape = data.size.width > data.size.height;
final isPortrait = !isLandscape;
```

```dart
// when screen is landscape
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

// when screen is portrait
bottomNavigationBar: isPortrait
    ? BottomNavigationBar(
        items: barItems,
        currentIndex: currentIndex,
        onTap: _onSortingSelected,
      )
    : null,
```

#### Fun with Flags

![](https://media.giphy.com/media/qUlkYKZX6bqvK/giphy.gif)

This is [a visual list of](https://commons.wikimedia.org/wiki/File:Map_germany_with_coats-of-arms.png) German states. It probably won't change in 2021 unless Bavaria declares independence.

Let's use coat of arms of respective states, and display them next to vaccination progress results.

Based on wiki page, define a map with appropriate images:

```dart
const coatOfArms = <String, String>{
  "Baden-Württemberg":
      "https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Coat_of_arms_of_Baden-W%C3%BCrttemberg_%28lesser%29.svg/200px-Coat_of_arms_of_Baden-W%C3%BCrttemberg_%28lesser%29.svg.png",
  "Bayern":
      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Bayern_Wappen.svg/200px-Bayern_Wappen.svg.png",
  /// ...and so on
};
```

Full list available [here](https://gist.github.com/vishna/9cfa8a08b752351608319d5ce4ccae77)

#### Use Cached Network Image

To display those logos we need to add [cached network image](https://pub.dev/packages/cached_network_image) to the list of our dependencies.

Modify `pubspec.yaml` so that it has this dependency:

```yaml
dependencies:
  http: ^0.12.2
  cached_network_image: ^2.5.0
  flutter:
    sdk: flutter
```

You might need to cold restart the app to update platform's deps.

#### Add image to list item

In the `StateEntryWidget` modify build so that you have logo link resolved in the build method and use `CachedNetworkImage`

```dart
Widget build(BuildContext context) {
  final imageUrl = coatOfArms[entry.name]; // add this
  return InkWell(
    // ...
    child: Row(
      children: [
        // add this
        if (imageUrl != null) CachedNetworkImage(
          imageUrl: imageUrl
        ),
        // other vaccination data
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
```

while this works, logo is too large, let's quickly ask it to be a bit smaller:

```dart
CachedNetworkImage(
  height: 40.0,
  width: 40.0,
  imageUrl: imageUrl,
),
```

Notice there's no padding on the left side of the state logo. Let's fix it:

- Remove all existing paddings from the `StateEntryWidget` (use refactor tool)
- Wrap entire `Row` with 8dp padding (use refactor tool again)
- Add 8dp spacing between logo & state name and between name & percent count

Define:

```dart
const SPACING_8DP = SizedBox(width: 8);
```

### Let's get organized

As we were developping our app, our single file codebase grew to over 350 LOC. It's not terrible yet but might get very ugly very quickly.

Let's split our code into following folders/files:

- lib/main.dart (app entry)
- lib/misc (stuff)
- lib/models (api classes, enums etc.)
- lib/widgets (reusable widgets but not screens)
- lib/screens (widgets that have `Scaffold` as their base, use widgets to build those screens)

so your structure looks something like this:

<img width="370" alt="Screenshot 2021-02-10 at 23 07 01" src="https://user-images.githubusercontent.com/121164/107579240-206b6200-6bf5-11eb-94c9-1e9bb7e98232.png">

This means renaming `MyHomePage` and `SecondRoute` to something more appropriate

### Fix delegation in StateEntryWidget

`StateEntryWidget` calls __out of the blue__ a new page `StateDetailScreen` when tapped. It would make sense to make it more reusable by removing this logic from the widget to somewhere more appropriate. We can do this by providing `onTap` as a class constructor parameter.

Use:

```dart
final void Function() onTap;
```

or predefined typedef alias:
```dart
final VoidCallback onTap;
```

...so this:

```dart
class StateEntryWidget extends StatelessWidget {
  final StateEntry entry;

  const StateEntryWidget({Key key, this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = coatOfArms[entry.name];
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StateDetailScreen(
              entry: entry,
            ),
          ),
        );
      },
```

becomes this:

```dart
class StateEntryWidget extends StatelessWidget {
  final StateEntry entry;
  final VoidCallback onTap;

  const StateEntryWidget({Key key, this.entry, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = coatOfArms[entry.name];
    return InkWell(
      onTap: onTap,
```

Therefore the existing closure needs to be moved from `StateEntryWidget` to `StatesScreen`

### Adaptive Layout with Layout Builder

So far our list work pretty ok in portrait mode, but as soon as we switch to landscape or desktop, there's a lot of wasted space.

We want to fix this by introducing a grid if a width is more than `800`

For this we'll use LayoutBuilder combined with GridView

[![](https://img.youtube.com/vi/bLOtZDTm4H8/0.jpg)](https://www.youtube.com/watch?v=bLOtZDTm4H8)

[![](https://img.youtube.com/vi/IYDVcriKjsw/0.jpg)](https://www.youtube.com/watch?v=IYDVcriKjsw)

We can quickly change ListView to GridView with:

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
```

This doesn't look good yet, but here's where `LayoutBuilder` comes in. We extract first `itemBuilder` closure which we can reuse across `ListView` and `GridView`

```dart
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
```

Refactor and wrap our GridView with LayoutBuilder (refactor tool gives StreamBuilder as an option, use that and change signature).

```dart
return LayoutBuilder(builder: (context, constraints) {
  if (constraints.maxWidth > 800.0) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: itemBuilder,
      itemCount: items.length,
    );
  } else {
    return ListView.builder(
      itemBuilder: itemBuilder,
      itemCount: items.length,
    );
  }
});
```

Now we just need more suitable `StateEntryWidget` when we combine it with `GridView`. We'll adapt it again using `LayoutBuilder`. Let's refactor current Row friendly layout to `_RowWidget`:

```dart
class StateEntryWidget extends StatelessWidget {
  final StateEntry entry;
  final VoidCallback onTap;

  const StateEntryWidget({Key key, this.entry, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _RowWidget(
            entry: entry,
          )),
    );
  }
}

class _RowWidget extends StatelessWidget {
  const _RowWidget({Key key, this.entry}) : super(key: key);
  final StateEntry entry;

  @override
  Widget build(BuildContext context) {
    final imageUrl = coatOfArms[entry.name];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // coat of arms
          if (imageUrl != null)
            CachedNetworkImage(
              height: 40.0,
              width: 40.0,
              imageUrl: imageUrl,
            ),
          // data
          if (imageUrl != null) SPACING_8DP,
          Expanded(
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
          SPACING_8DP,
          Text(
            "${entry.status.quote}%",
            style: Theme.of(context).textTheme.headline4,
          )
        ],
      ),
    );
  }
}
```

Copy paste `_RowWidget` and rename it to `_SquareWidget`. Adjust it to look better in the grid.

```dart
class _GridWidget extends StatelessWidget {
  const _GridWidget({Key key, this.entry}) : super(key: key);
  final StateEntry entry;

  @override
  Widget build(BuildContext context) {
    final imageUrl = coatOfArms[entry.name];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // coat of arms
          if (imageUrl != null)
            CachedNetworkImage(
              height: 100.0,
              width: 100.0,
              imageUrl: imageUrl,
            ),
          // data
          if (imageUrl != null) V_SPACING_8DP,
          Text(
            entry.name,
            style: Theme.of(context).textTheme.headline5,
          ),
          V_SPACING_8DP,
          Text(
            "${entry.status.quote}%",
            style: Theme.of(context).textTheme.headline4,
          ),
          V_SPACING_8DP,
          Text(
              "${entry.status.vaccinated} out of ${entry.status.total} vaccinted"),
        ],
      ),
    );
  }
}
```

Now we just need to make sure we use `_GridWidget` when in `GridView` and `_RowWidget` when in `ListView`. We can use `LayoutBuilder` for this again!

```dart
Padding(
  padding: const EdgeInsets.all(8.0),
  child: LayoutBuilder(
    builder: (context, constraints) {
      /// if height has no constraints, it is a list view
      if (constraints.hasBoundedHeight) {
        return _GridWidget(
          entry: entry,
        );
      } else {
        return _RowWidget(
          entry: entry,
        );
      }
    },
  ),
)
```

We can further tweak the grid behavior by modifing delegate properties:

```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  mainAxisExtent: 250,
)
```

We can also limit the grid size so it doesn't exceed e.g. width of `1000` on very large screens:

```dart
Center(
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
)
```

[![](https://img.youtube.com/vi/o2KveVr7adg/0.jpg)](https://www.youtube.com/watch?v=o2KveVr7adg)

### Hero Transition

First let's make detail screen less boring and display coat of arms there centered.

```dart
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
        child: CachedNetworkImage(
          height: 200.0,
          width: 200.0,
          imageUrl: imageUrl,
        ),
      ),
    );
  }
}
```

Let's use `Hero` widget to transition logo between screens!

[![](https://img.youtube.com/vi/Be9UH1kXFDw/0.jpg)](https://www.youtube.com/watch?v=Be9UH1kXFDw)

Hero element needs a unique tag, in our case we can use land's name for it, so:

```dart
Hero(
  tag: entry.name,
  child: CachedNetworkImage(
    height: 40.0,
    width: 40.0,
    imageUrl: imageUrl,
  ),
)
```

This wrapping must happen both in `StateEntryWidget` and `StateDetailScreen` so that flutter can know how to connect the dots.

## OPTIONAL

### Add vaccine manufacturers parsing

Add parsing for this part of the json respose:

<img width="425" alt="Screenshot 2021-02-13 at 19 13 24" src="https://user-images.githubusercontent.com/121164/107857697-43358a80-6e30-11eb-8317-96fa79f3e70d.png">

Add `VaccineManufacturer` class:

```dart
class VaccineManufacturer {
  const VaccineManufacturer({this.name, this.amount});

  final String name;
  final int amount;
}
```

and `manufacturers` field to the `VaccineStatus` class:

```dart
final vaccinated_by_accine =
        json['vaccinated_by_accine'] as Map<String, dynamic>;

manufacturers: vaccinated_by_accine.keys
  .map((name) => VaccineManufacturer(
      name: name, amount: vaccinated_by_accine[name]))
  .toList()
```

__NOTE:__ check the API response, it might be the typo in __vaccinated_by_accine__ has been fixed by the time you're reading this.

### Display vaccine manufacturers in details screen

Search pub.dev for some chart library and use it in details screen to display data.

https://pub.dev/packages?q=chart

I picked the first from the list - [fl_chart](https://pub.dev/packages/fl_chart). Looks fancy and I want to use [pie chart](https://github.com/imaNNeoFighT/fl_chart/blob/master/repo_files/documentations/pie_chart.md) to display these manufacturers info.

Going to shamelessly copy-paste this snippet and then adapt it:

https://github.com/imaNNeoFighT/fl_chart/blob/master/example/lib/pie_chart/samples/pie_chart_sample2.dart

```
cd lib/widgets
wget https://raw.githubusercontent.com/imaNNeoFighT/fl_chart/master/example/lib/pie_chart/samples/pie_chart_sample2.dart
# it will complain about missing indicator file so let's get that too
wget https://raw.githubusercontent.com/imaNNeoFighT/fl_chart/master/example/lib/pie_chart/samples/indicator.dart
```

Then let's wrap our existing coat of arms with a Column using refactor tool and add `PieChartSample2`to the mix. We can remove `Center` widget and use column's mainAxisAlignment: MainAxisAlignment.center instead:

```dart
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
          PieChartSample2(),
        ],
      ),
    );
  }
}
```

### Butcher PieChartSample2

We have integrated a 3rd party component without knowing how it works, now we just need to make it display data we want.

Inspecting `PieChart2State`'s `build` method reveals we have a "hardcoded" legend of `Indicator`s inside a `Column` and data set is provided by a `showingSections`. Moreover the pie chart requires a color which is not a part of our vaccination data so we need to come up with some replacement.

We'll define a list of 10 unique colors and assign the to different vaccines based on the index in the array.

```dart
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
```

VSCode shows you colors next to the line number - picking colors that should be easy to distinguish from each other.

<img width="246" alt="Screenshot 2021-02-14 at 15 17 29" src="https://user-images.githubusercontent.com/121164/107879215-d1188080-6ed7-11eb-88a2-91d2eec4a7b1.png">

#### Pass data

We need to pass list of manufacturers to the `PieChartSample2` widget. Let's define final field on the PieChartSample2.

```dart
const PieChartSample2({Key key, this.manufactureres}) : super(key: key);
  final List<VaccineManufacturer> manufactureres;
```

Then go back to `StateDetailScreen` and pass those manufactureres:

```dart
PieChartSample2(
  manufactureres: entry.status.manufacturers,
)
```

Let's use this to array now to populate the legend:

```dart
Column(
  mainAxisSize: MainAxisSize.max,
  mainAxisAlignment: MainAxisAlignment.end,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: <Widget>[
    /// it's a for loop in an array!
    for (int i = 0; i < widget.length; i++) ...[
      Indicator(
        color: _colors[i],
        /// IMPORTANT: fix state class to extend from State<PieChartSample2>
        /// otherwise you won't be able to access manufacturers field
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
```

Finally let's give the right numbers to the pie itself. First, we need total amount:

```dart
/// https://stackoverflow.com/a/13611678
final int totalSum = widget.manufactureres
    .fold(0, (previous, current) => previous + current.amount);
```

Then we need our manufacturers list to a list of `PieChartSecionData` thus:

```dart
List<PieChartSectionData> showingSections() {
  /// https://stackoverflow.com/a/13611678
  final int totalAmount = widget.manufactureres
      .fold(0, (previous, current) => previous + currentamount);

  return widget.manufactureres.mapIndexed((manufacturer,index) {
    final isTouched = index == touchedIndex;
    final double fontSize = isTouched ? 25 : 16;
    final double radius = isTouched ? 60 : 50;
    final percentValue =
        100.0 * manufacturer.amount.toDouble() /totalAmount.toDouble();
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
```

Dart doesn't come with `mapIndexed` method - we'll define ours instead:

```dart
extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndexed<T>(T f(E e, int i)) {
    var i = 0;
    return this.map((e) => f(e, i++));
  }
}
```

Let's do some final tweaks, make Aspect Ratio 2:1, remove Card and change some positioning:

```
@override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Row(
        children: <Widget>[
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
            mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }
```

You should get something that look like this:

<img width="667" alt="Screenshot 2021-02-14 at 17 17 22" src="https://user-images.githubusercontent.com/121164/107882252-88b58e80-6ee8-11eb-9ac0-9897b0e3cad1.png">

### Or try different library...

E.g. https://pub.dev/packages/charts_flutter

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vaxxometer/misc/coat_of_arms.dart';
import 'package:vaxxometer/misc/design.dart';
import 'package:vaxxometer/models/state_entry.dart';
import 'package:vaxxometer/widgets/donut_auto_label_chart.dart';

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
      body: ListView(
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
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: Center(child: DonutAutoLabelChart.withSampleData()),
          ),
          V_SPACING_8DP,
        ],
      ),
    );
  }
}
```

then we just need to adapt `withSampleData`