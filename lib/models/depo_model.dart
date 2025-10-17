class Depo {
  final String id;
  final String firmaId;
  final String subeId;
  final String ad;

  Depo({
    required this.id,
    required this.firmaId,
    required this.subeId,
    required this.ad,
  });

  factory Depo.fromMap(String id, Map<String, dynamic> map) {
    return Depo(
      id: id,
      firmaId: map['firmaId'] ?? '',
      subeId: map['subeId'] ?? '',
      ad: map['ad'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'firmaId': firmaId,
    'subeId': subeId,
    'ad': ad,
  };
}
