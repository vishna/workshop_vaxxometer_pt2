class VaccineStatus {
  const VaccineStatus(
      {this.total,
      this.vaccinated,
      this.difference_to_the_previous_day,
      this.quote,
      this.split});
  final int total;
  final int vaccinated;
  final int difference_to_the_previous_day;
  final double quote;
  final VaccineSplit split;

  factory VaccineStatus.fromJson(Map<String, dynamic> json) {
    return VaccineStatus(
      total: json['total'],
      vaccinated: json['vaccinated'],
      difference_to_the_previous_day: json['difference_to_the_previous_day'],
      quote: json['quote'],
      split: VaccineSplit.fromJson(json['vaccinated_by_accine']),
    );
  }
}

class VaccineSplit {
  const VaccineSplit({this.biontech, this.moderna, this.astrazeneca});

  final int biontech;
  final int moderna;
  final int astrazeneca;

  factory VaccineSplit.fromJson(Map<String, dynamic> json) {
    return VaccineSplit(
      biontech: json['biontech'],
      moderna: json['moderna'],
      astrazeneca: json['astrazeneca'],
    );
  }
}
