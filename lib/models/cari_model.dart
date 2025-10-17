class Cari {
  final String id;
  final String ad;
  final String telefon;
  final String adres;
  final String gmail;

  Cari({
    required this.id,
    required this.ad,
    required this.telefon,
    required this.adres,
    required this.gmail,
  });

  factory Cari.fromMap(String id, Map<String, dynamic> map) {
    return Cari(
      id: id,
      ad: map['ad'] ?? '',
      telefon: map['telefon'] ?? '',
      adres: map['adres'] ?? '',
      gmail: map['gmail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ad': ad,
      'telefon': telefon,
      'adres': adres,
      'gmail': gmail,
    };
  }
}
