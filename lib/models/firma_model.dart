class Firma {
  final String id;
  final String ad;

  Firma({required this.id, required this.ad});

  factory Firma.fromMap(String id, Map<String, dynamic> map) {
    return Firma(
      id: id,
      ad: map['ad'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'ad': ad};
}

