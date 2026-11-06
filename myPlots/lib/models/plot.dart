/// Модели данных приложения MyPlotsApp (порт с React Native на Flutter).
/// Структура полностью соответствует оригиналу (src/types/index.ts).
library;

/// Квартира
class Apartment {
  final String id;
  final int number;
  final String? color; //hex, например '#4CAF50', или null
  final String comment;

  Apartment({
    required this.id,
    required this.number,
    this.color,
    this.comment = '',
  });

  factory Apartment.fromMap(Map<String, dynamic> map, {required String id}) {
    return Apartment(
      id: id,
      number: _toInt(map['number']),
      color: map['color'] as String?,
      comment: map['comment'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'color': color,
      'comment': comment,
    };
  }

  Apartment copyWith({
    String? id,
    int? number,
    String? color,
    String? comment,
  }) {
    return Apartment(
      id: id ?? this.id,
      number: number ?? this.number,
      color: color ?? this.color,
      comment: comment ?? this.comment,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Apartment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          number == other.number &&
          color == other.color &&
          comment == other.comment;

  @override
  int get hashCode =>
      id.hashCode ^ number.hashCode ^ color.hashCode ^ comment.hashCode;
}

/// Этаж
class Floor {
  final String id;
  final int number;
  final List<Apartment> apartments;

  Floor({
    required this.id,
    required this.number,
    required this.apartments,
  });

  factory Floor.fromMap(Map<String, dynamic> map, {required String id}) {
    return Floor(
      id: id,
      number: _toInt(map['number']),
      apartments: (map['apartments'] as List? ?? [])
          .map<dynamic>((e) => e)
          .map<Apartment>((e) => Apartment.fromMap(e as Map<String, dynamic>,
              id: (e as Map)['id'] as String? ?? ''))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'apartments': apartments.map((a) => a.toMap()).toList(),
    };
  }

  Floor copyWith({
    String? id,
    int? number,
    List<Apartment>? apartments,
  }) {
    return Floor(
      id: id ?? this.id,
      number: number ?? this.number,
      apartments: apartments ?? this.apartments,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Floor &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          number == other.number &&
          _listEquals(apartments, other.apartments);

  @override
  int get hashCode => id.hashCode ^ number.hashCode ^ apartments.hashCode;
}
/// Подъезд
class Entrance {
  final String id;
  final int number;
  final List<Floor> floors;

  Entrance({
    required this.id,
    required this.number,
    required this.floors,
  });

  factory Entrance.fromMap(Map<String, dynamic> map, {required String id}) {
    return Entrance(
      id: id,
      number: _toInt(map['number']),
      floors: (map['floors'] as List? ?? [])
          .map<Floor>((e) => Floor.fromMap(e as Map<String, dynamic>,
              id: (e as Map)['id'] as String? ?? ''))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'floors': floors.map((f) => f.toMap()).toList(),
    };
  }

  Entrance copyWith({String? id, int? number, List<Floor>? floors}) {
    return Entrance(
      id: id ?? this.id,
      number: number ?? this.number,
      floors: floors ?? this.floors,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entrance &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          number == other.number &&
          _listEquals(floors, other.floors);

  @override
  int get hashCode => id.hashCode ^ number.hashCode ^ floors.hashCode;
}

/// Параметры при создании участка
class PlotParams {
  final String name;
  final int entrances;
  final int floors;
  final int apartmentsPerFloor;
  final int startNumber;
  final String numberingScheme; // 'sequential' | 'byEntrance'

  PlotParams({
    required this.name,
    this.entrances = 2,
    this.floors = 5,
    this.apartmentsPerFloor = 4,
    this.startNumber = 1,
    this.numberingScheme = 'sequential',
  });

  factory PlotParams.fromMap(Map<String, dynamic> map) {
    return PlotParams(
      name: map['name'] as String? ?? '',
      entrances: _toInt(map['entrances']),
      floors: _toInt(map['floors']),
      apartmentsPerFloor: _toInt(map['apartmentsPerFloor']),
      startNumber: _toInt(map['startNumber']),
      numberingScheme: map['numberingScheme'] as String? ?? 'sequential',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'entrances': entrances,
      'floors': floors,
      'apartmentsPerFloor': apartmentsPerFloor,
      'startNumber': startNumber,
      'numberingScheme': numberingScheme,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlotParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          entrances == other.entrances &&
          floors == other.floors &&
          apartmentsPerFloor == other.apartmentsPerFloor &&
          startNumber == other.startNumber &&
          numberingScheme == other.numberingScheme;

  @override
  int get hashCode =>
      name.hashCode ^
      entrances.hashCode ^
      floors.hashCode ^
      apartmentsPerFloor.hashCode ^
      startNumber.hashCode ^
      numberingScheme.hashCode;
}

/// Участок (хранится в коллекции Firestore 'plots')
class Plot {
  final String id;
  final String name;
  final List<Entrance> entrances;
  final PlotParams params;

  Plot({
    required this.id,
    required this.name,
    required this.entrances,
    required this.params,
  });

  factory Plot.fromMap(Map<String, dynamic> map, {required String id}) {
    return Plot(
      id: id,
      name: map['name'] as String? ?? '',
      entrances: (map['entrances'] as List? ?? [])
          .map<Entrance>((e) => Entrance.fromMap(e as Map<String, dynamic>,
              id: (e as Map)['id'] as String? ?? ''))
          .toList(),
      params: PlotParams.fromMap(map['params'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'entrances': entrances.map((e) => e.toMap()).toList(),
      'params': params.toMap(),
    };
  }

  Plot copyWith({
    String? id,
    String? name,
    List<Entrance>? entrances,
    PlotParams? params,
  }) {
    return Plot(
      id: id ?? this.id,
      name: name ?? this.name,
      entrances: entrances ?? this.entrances,
      params: params ?? this.params,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Plot &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          _listEquals(entrances, other.entrances) &&
          params == other.params;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ entrances.hashCode ^ params.hashCode;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}