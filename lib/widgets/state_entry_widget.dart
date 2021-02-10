import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vaxxometer/misc/coat_of_arms.dart';
import 'package:vaxxometer/misc/design.dart';
import 'package:vaxxometer/models/state_entry.dart';
import 'package:vaxxometer/screens/state_detail_screen.dart';

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
          // FIXME this shouldn't be here, pass callback instead
          MaterialPageRoute(
            builder: (context) => StateDetailScreen(
              entry: entry,
            ),
          ),
        );
      },
      child: Padding(
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
      ),
    );
  }
}
