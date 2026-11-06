import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/plot.dart';
import '../services/plot_service.dart';

/// Провайдер участков (аналог PlotsContext из React Native).
/// Слушает авторизацию и при наличии пользователя подписывается на снимки Firestore.
class PlotsProvider extends ChangeNotifier {
  final PlotService _service = PlotService();
  final List<Plot> _plots = [];
  bool _loading = true;
  String? _error;

  StreamSubscription? _authSub;
  StreamSubscription? _plotsSub;

  List<Plot> get plots => List.unmodifiable(_plots);
  bool get loading => _loading;
  String? get error => _error;

  PlotsProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _error = null;
      if (user == null) {
        _stopPlots();
        _plots.clear();
        _loading = false;
        notifyListeners();
      } else {
        _startPlots();
      }
    });
    // Начальная проверка (если пользователь уже авторизован при запуске)
    _maybeStartPlots();
  }

  void _maybeStartPlots() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _startPlots();
    } else {
      _loading = false;
      notifyListeners();
    }
  }

  void _startPlots() {
    _stopPlots();
    _loading = true;
    _error = null;
    notifyListeners();
    _plotsSub = _service.plotsStream().listen((plots) {
      _plots
        ..clear()
        ..addAll(plots);
      _loading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    });
  }

  void _stopPlots() {
    _plotsSub?.cancel();
    _plotsSub = null;
  }

  /// Генерирует подъезды/этажи/квартиры по параметрам (перенос логики generateEntrancesWithParams).
  static List<Entrance> generateEntrancesWithParams(PlotParams params) {
    final entrances = <Entrance>[];
    for (int e = 1; e <= params.entrances; e++) {
      final floors = <Floor>[];
      for (int f = 1; f <= params.floors; f++) {
        final apartments = <Apartment>[];
        for (int a = 1; a <= params.apartmentsPerFloor; a++) {
          int number;
          if (params.numberingScheme == 'sequential') {
            final apartmentsBefore =
                (e - 1) * params.floors * params.apartmentsPerFloor +
                (f - 1) * params.apartmentsPerFloor +
                (a - 1);
            number = params.startNumber + apartmentsBefore;
          } else {
            // byEntrance
            number = params.startNumber + (f - 1) * params.apartmentsPerFloor + (a - 1);
          }
          apartments.add(Apartment(
            id: 'e$e$f$a$a',
            number: number,
            color: null,
            comment: '',
          ));
        }
        floors.add(Floor(id: 'e$e$f$f', number: f, apartments: apartments));
      }
      entrances.add(Entrance(id: 'e$e', number: e, floors: floors));
    }
    return entrances;
  }

  /// Создать новый участок в Firestore.
  Future<bool> addPlot(PlotParams params) async {
    _setLoading(true);
    try {
      final plot = Plot(
        id: '', // Firestore назначит id при add
        name: params.name,
        entrances: generateEntrancesWithParams(params),
        params: params,
      );
      await _service.addPlot(plot);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Обновить существующий участок.
  Future<bool> updatePlot(Plot plot) async {
    _setLoading(true);
    try {
      await _service.updatePlot(plot);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Удалить участок по id.
  Future<bool> deletePlot(String plotId) async {
    try {
      await _service.deletePlot(plotId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _plotsSub?.cancel();
    super.dispose();
  }
}