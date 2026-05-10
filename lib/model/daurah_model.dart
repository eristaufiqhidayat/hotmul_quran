class Daurah {
  final int id;
  final String name;

  Daurah({required this.id, required this.name});

  factory Daurah.fromJson(Map<String, dynamic> json) {
    return Daurah(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
    );
  }
}
