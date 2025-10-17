class SenkronDurum {
  final String id;
  final String koleksiyonAdi;
  final bool basarili;
  final DateTime zaman;
  final String mesaj;

  SenkronDurum({
    required this.id,
    required this.koleksiyonAdi,
    required this.basarili,
    required this.zaman,
    required this.mesaj,
  });

  Map<String, dynamic> toMap() {
    return {
      "koleksiyonAdi": koleksiyonAdi,
      "basarili": basarili,
      "zaman": zaman.toIso8601String(),
      "mesaj": mesaj,
    };
  }

  factory SenkronDurum.fromMap(String id, Map<String, dynamic> data) {
    return SenkronDurum(
      id: id,
      koleksiyonAdi: data["koleksiyonAdi"],
      basarili: data["basarili"],
      zaman: DateTime.parse(data["zaman"]),
      mesaj: data["mesaj"],
    );
  }
}
