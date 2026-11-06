import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plots_provider.dart';
import '../models/plot.dart';

/// Экран деталей участка (перенос app/plot/[id].tsx).
class PlotDetailScreen extends StatelessWidget {
  final String plotId;
  const PlotDetailScreen({super.key, required this.plotId});

  Color _color(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey.shade300;
    switch (hex) {
      case 'red': return Colors.red;
      case 'yellow': return Colors.yellow;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'orange': return Colors.orange;
      case 'purple': return Colors.purple;
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
    }
    final h = hex.replaceAll('#', '');
    try {
      return Color(int.parse('0xFF$h'));
    } catch (_) {
      return Colors.grey.shade300;
    }
  }

  /// Неизменяемое обновление одной квартиры во вложенной структуре подъездов/этажей.
  List<Entrance> _updateApartment(List<Entrance> entrances, String aptId,
      {String? color, String? comment}) {
    final result = <Entrance>[];
    for (final e in entrances) {
      final newFloors = <Floor>[];
      for (final f in e.floors) {
        final newApts = f.apartments.map((a) {
          if (a.id != aptId) return a;
          return a.copyWith(color: color ?? a.color, comment: comment ?? a.comment);
        }).toList();
        newFloors.add(f.copyWith(apartments: newApts));
      }
      result.add(e.copyWith(floors: newFloors));
    }
    return result;
  }
  Widget _colorChip(BuildContext ctx, String? hex, String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      avatar: CircleAvatar(backgroundColor: _color(hex), radius: 10),
      onSelected: selected ? null : (_) => onTap(),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Plot plot, PlotsProvider provider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить участок'),
        content: Text('Удалить "${plot.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await provider.deletePlot(plot.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
    Future<void> _editApartment(BuildContext context, Plot plot, Apartment apt) async {
    String? color = apt.color;
    final commentCtrl = TextEditingController(text: apt.comment);
    final provider = context.read<PlotsProvider>();

    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: Text('Квартира №${apt.number}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Цвет:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _colorChip(dialogCtx, null, 'Без цвета', color == null, () => setDialogState(() => color = null)),
                      _colorChip(dialogCtx, '#4CAF50', 'Зелёный', color == '#4CAF50', () => setDialogState(() => color = '#4CAF50')),
                      _colorChip(dialogCtx, '#F44336', 'Красный', color == '#F44336', () => setDialogState(() => color = '#F44336')),
                      _colorChip(dialogCtx, '#FFC107', 'Жёлтый', color == '#FFC107', () => setDialogState(() => color = '#FFC107')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(labelText: 'Комментарий', border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Отмена')),
                ElevatedButton(
                    onPressed: () async {
                      final newEntrances = _updateApartment(plot.entrances, apt.id, color: color, comment: commentCtrl.text);
                    final ok = await provider.updatePlot(plot.copyWith(entrances: newEntrances));
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.error ?? 'Ошибка сохранения')),
                      );
                    }
                    if (context.mounted) Navigator.of(dialogCtx).pop();
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали участка')),
      body: Consumer<PlotsProvider>(
        builder: (ctx, plots, _) {
          if (plots.loading) return const Center(child: CircularProgressIndicator());
          if (plots.error != null) {
            return Center(child: Text('Ошибка: ${plots.error}', style: const TextStyle(color: Colors.red)));
          }
          final plot = plots.plots.firstWhere((p) => p.id == plotId, orElse: () => throw Exception('not found'));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plot.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${plot.entrances.length} подъезд(ов)', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ...plot.entrances.map((e) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 6, top: 14),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Text('Подъезд ${e.number}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        ...e.floors.map((f) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Text('Этаж ${f.number}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                ),
                                Wrap(
                                  spacing: 10, runSpacing: 10,
                                  children: f.apartments.map((a) {
                                    final hasComment = a.comment.isNotEmpty;
                                    return GestureDetector(
                                      onTap: () => _editApartment(ctx, plot, a),
                                      child: Container(
                                        width: 60, height: 60,
                                        decoration: BoxDecoration(
                                          color: _color(a.color),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade400),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('${a.number}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            if (hasComment) const Icon(Icons.comment, size: 14, color: Colors.blue),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            )),
                      ],
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Удалить участок', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    onPressed: plots.loading ? null : () => _confirmDelete(context, plot, plots),
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}