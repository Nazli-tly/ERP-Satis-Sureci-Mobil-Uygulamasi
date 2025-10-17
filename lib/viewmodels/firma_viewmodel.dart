import 'package:flutter/foundation.dart';
import '../models/firma_model.dart';
import '../models/sube_model.dart';
import '../models/depo_model.dart';
import '../services/firma_service.dart';

class FirmaViewModel extends ChangeNotifier {
  final FirmaService _service = FirmaService();

  // temel listeler / mapler
  List<Firma> firmalar = [];
  final Map<String, List<Sube>> subelerByFirma = {};
  final Map<String, List<Depo>> depolarBySube = {};

  // yükleme durumları
  bool isLoadingFirmalar = false;
  final Map<String, bool> subeLoading = {}; // firmaId -> loading
  final Map<String, bool> depoLoading = {}; // subeId -> loading

  // Firmaları yükle
  Future<void> loadFirmalar() async {
    isLoadingFirmalar = true;
    notifyListeners();
    try {
      firmalar = await _service.getFirmalar();
    } finally {
      isLoadingFirmalar = false;
      notifyListeners();
    }
  }

  // Firma'ya ait şubeleri getir (force=true ile yeniden çek)
  Future<void> loadSubelerFor(String firmaId, {bool force = false}) async {
    if (!force && subelerByFirma.containsKey(firmaId)) return;
    subeLoading[firmaId] = true;
    notifyListeners();
    try {
      final list = await _service.getSubeler(firmaId);
      subelerByFirma[firmaId] = list;
    } catch (e) {
      // hata yönetimi isteğe bağlı
      subelerByFirma[firmaId] = [];
    } finally {
      subeLoading[firmaId] = false;
      notifyListeners();
    }
  }

  // Şube'ye ait depoları getir (force=true ile yeniden çek)
  Future<void> loadDepolarFor(String firmaId, String subeId,
      {bool force = false}) async {
    if (!force && depolarBySube.containsKey(subeId)) return;
    depoLoading[subeId] = true;
    notifyListeners();
    try {
      final list = await _service.getDepolar(firmaId, subeId);
      depolarBySube[subeId] = list;
    } catch (e) {
      depolarBySube[subeId] = [];
    } finally {
      depoLoading[subeId] = false;
      notifyListeners();
    }
  }

  // Ekleme işlemleri (ekledikten sonra ilgili listeyi yeniden yükler)
  Future<void> addFirma(Firma f) async {
    await _service.addFirma(f);
    await loadFirmalar();
  }

  Future<void> addSube(String firmaId, Sube s) async {
    await _service.addSube(s);
    await loadSubelerFor(firmaId, force: true);
  }

  Future<void> addDepo(String firmaId, String subeId, Depo d) async {
    await _service.addDepo(d);
    await loadDepolarFor(firmaId, subeId, force: true);
  }
  Future<void> deleteSube(String firmaId, String subeId) async {
    await _service.deleteSube(firmaId, subeId);
    subelerByFirma[firmaId]?.removeWhere((s) => s.id == subeId);
    notifyListeners();
  }

  Future<void> deleteDepo(String firmaId, String subeId, String depoId) async {
    await _service.deleteDepo(firmaId, subeId, depoId);
    depolarBySube[subeId]?.removeWhere((d) => d.id == depoId);
    notifyListeners();
  }
}
