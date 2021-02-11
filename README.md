## Vaxxometer Workshop, 12/02/2021

### Carry over work from 1st workshop

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

We want to fix this by introducing a grid if a width is more than `200`

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

This doesn't look good yet, but here's where `LayoutBuilder` comes in:
