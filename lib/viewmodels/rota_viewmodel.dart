import 'package:flutter/material.dart';
import '../models/rota_item_model.dart';
import '../services/rota_service.dart';

class RotaViewModel extends ChangeNotifier {
  final RotaService _service = RotaService();
  List<Rota> _rotalar = [];
  bool _isLoading = false;

  List<Rota> get rotalar => _rotalar;
  bool get isLoading => _isLoading;

  Future<void> loadOnayliRotalar() async {
    _isLoading = true;
    notifyListeners();

    _rotalar = await _service.getOnayliRotalar();

    _isLoading = false;
    notifyListeners();
  }
}

