import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plot.dart';

/// Сервис для работы с участками в Firestore (логика из src/services/firebase.ts + PlotsContext).
class PlotService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'plots';

  /// Поток всех участков (аналог onSnapshot на коллекцию 'plots').
  Stream<List<Plot>> plotsStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Plot.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  /// Добавить участок (без поля id — оно назначается Firestore).
  Future<void> addPlot(Plot plot) async {
    await _db.collection(_collection).add(_withoutId(plot.toMap()));
  }

  /// Обновить участок по id (без поля id в теле документа).
  Future<void> updatePlot(Plot plot) async {
    await _db.collection(_collection).doc(plot.id).update(_withoutId(plot.toMap()));
  }

  /// Удалить участок по id.
  Future<void> deletePlot(String plotId) async {
    await _db.collection(_collection).doc(plotId).delete();
  }

  DocumentReference plotDoc(String plotId) =>
      _db.collection(_collection).doc(plotId);

  Map<String, dynamic> _withoutId(Map<String, dynamic> data) {
    final copy = Map<String, dynamic>.from(data);
    copy.remove('id');
    return copy;
  }
}