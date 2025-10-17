class Ayarlar {
  final String id;
  final String userId;
  final String adSoyad;
  final String telefon;
  final String departman;
  final String tema;

  Ayarlar({
    required this.id,
    required this.userId,
    required this.adSoyad,
    required this.telefon,
    required this.departman,
    required this.tema,
  });

  factory Ayarlar.fromMap(String id, Map<String, dynamic> map) {
    return Ayarlar(
      id: id,
      userId: map["userId"] ?? "",
      adSoyad: map["adSoyad"] ?? "",
      telefon: map["telefon"] ?? "",
      departman: map["departman"] ?? "",
      tema: map["tema"] ?? "Aydınlık",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "adSoyad": adSoyad,
      "telefon": telefon,
      "departman": departman,
      "tema": tema,
    };
  }
}
