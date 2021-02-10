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