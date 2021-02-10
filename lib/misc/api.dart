import 'dart:convert';

import 'package:vaxxometer/models/state_entry.dart';
import 'package:http/http.dart' as http;
import 'package:vaxxometer/models/vaccine_status.dart';

Future<List<StateEntry>> fetchData() async {
  final response =
      await http.get('https://rki-vaccination-data.vercel.app/api');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return parseResponse(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load vaccination data');
  }
}

List<StateEntry> parseResponse(String jsonStr) {
  final json = jsonDecode(jsonStr);
  final statesMap = json["states"] as Map<String, dynamic>;
  return statesMap.keys.map((key) {
    final vaccineStatusJson = statesMap[key];
    return StateEntry(
      status: VaccineStatus.fromJson(vaccineStatusJson),
      name: key,
    );
  }).toList();
}
