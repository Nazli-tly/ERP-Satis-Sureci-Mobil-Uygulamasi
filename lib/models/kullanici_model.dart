class Kullanici {
  final String id;
  String? adSoyad;
  String? email;
  String? telefon;
  String? profilUrl;

  Kullanici({
    required this.id,
    this.adSoyad,
    this.email,
    this.telefon,
    this.profilUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      "adSoyad": adSoyad,
      "email": email,
      "telefon": telefon,
      "profilUrl": profilUrl,
    };
  }

  factory Kullanici.fromMap(String id, Map<String, dynamic> data) {
    return Kullanici(
      id: id,
      adSoyad: data["adSoyad"],
      email: data["email"],
      telefon: data["telefon"],
      profilUrl: data["profilUrl"],
    );
  }
}
