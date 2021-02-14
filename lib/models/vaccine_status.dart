class VaccineStatus {
  const VaccineStatus(
      {this.total,
      this.vaccinated,
      this.difference_to_the_previous_day,
      this.quote,
      this.manufacturers});
  final int total;
  final int vaccinated;
  final int difference_to_the_previous_day;
  final double quote;
  final List<VaccineManufacturer> manufacturers;

  factory VaccineStatus.fromJson(Map<String, dynamic> json) {
    final vaccinated_by_accine =
        json['vaccinated_by_accine'] as Map<String, dynamic>;

    return VaccineStatus(
      total: json['total'],
      vaccinated: json['vaccinated'],
      difference_to_the_previous_day: json['difference_to_the_previous_day'],
      quote: json['quote'],
      manufacturers: vaccinated_by_accine.keys
          .map((name) => VaccineManufacturer(
              name: name, amount: vaccinated_by_accine[name]))
          .toList(),
    );
  }
}

class VaccineManufacturer {
  const VaccineManufacturer({this.name, this.amount});

  final String name;
  final int amount;
}
