import 'package:vaxxometer/models/sorting_type.dart';
import 'package:vaxxometer/models/vaccine_status.dart';

class StateEntry {
  StateEntry({this.status, this.name});
  final VaccineStatus status;
  final String name;
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
