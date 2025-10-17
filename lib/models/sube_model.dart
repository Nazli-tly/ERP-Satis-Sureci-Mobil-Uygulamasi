class Sube {
  final String id;
  final String firmaId;
  final String ad;

  Sube({required this.id, required this.firmaId, required this.ad});

  factory Sube.fromMap(String id, Map<String, dynamic> map) {
    return Sube(
      id: id,
      firmaId: map['firmaId'] ?? '',
      ad: map['ad'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'firmaId': firmaId, 'ad': ad};
}

