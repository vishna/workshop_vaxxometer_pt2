import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vaxxometer/misc/coat_of_arms.dart';
import 'package:vaxxometer/misc/design.dart';
import 'package:vaxxometer/models/state_entry.dart';

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
      ),
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
            Hero(
              tag: entry.name,
              child: CachedNetworkImage(
                height: 40.0,
                width: 40.0,
                imageUrl: imageUrl,
              ),
            ),
          // data
          if (imageUrl != null) H_SPACING_8DP,
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
          H_SPACING_8DP,
          Text(
            "${entry.status.quote}%",
            style: Theme.of(context).textTheme.headline4,
          )
        ],
      ),
    );
  }
}

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
            Hero(
              tag: entry.name,
              child: CachedNetworkImage(
                height: 100.0,
                width: 100.0,
                imageUrl: imageUrl,
              ),
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
