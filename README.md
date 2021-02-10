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