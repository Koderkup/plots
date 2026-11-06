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

  Widget _colorChip(BuildContext ctx, String? hex, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: const SizedBox.shrink(),
      avatar: CircleAvatar(backgroundColor: _color(hex), radius: 10),
      selected: selected,
      onSelected: selected ? null : (_) => onTap(),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? _color(hex) : Colors.grey.shade300),
      ),
      selectedColor: _color(hex).withOpacity(0.2),
      backgroundColor: Colors.grey.shade100,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Future<void> _confirmDelete(BuildContext context, Plot plot, PlotsProvider provider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Удалить участок', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Удалить "${plot.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Квартира №${apt.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _colorChip(dialogCtx, null, color == null, () => setDialogState(() => color = null)),
                      _colorChip(dialogCtx, '#4CAF50', color == '#4CAF50', () => setDialogState(() => color = '#4CAF50')),
                      _colorChip(dialogCtx, '#F44336', color == '#F44336', () => setDialogState(() => color = '#F44336')),
                      _colorChip(dialogCtx, '#FFC107', color == '#FFC107', () => setDialogState(() => color = '#FFC107')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Комментарий:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Комментарий',
                      border: OutlineInputBorder(),
                    ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
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
      appBar: AppBar(
        title: const Text('Детали участка'),
        centerTitle: false,
        elevation: 0,
      ),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet, color: Colors.blue, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plot.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('${plot.entrances.length} подъезд(ов)', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...plot.entrances.map((e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8, top: 14),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.indigo.shade100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Подъезд ${e.number}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                              ],
                            ),
                          ),
                          ...e.floors.map((f) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      children: [
                                        Icon(Icons.layers, color: Colors.grey.shade400, size: 16),
                                        const SizedBox(width: 6),
                                        Text('Этаж ${f.number}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: f.apartments.map((a) {
                                      final hasComment = a.comment.isNotEmpty;
                                      return GestureDetector(
                                        onTap: () => _editApartment(ctx, plot, a),
                                        child: Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: _color(a.color),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade400, width: 1.5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('${a.number}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                              if (hasComment) const SizedBox(height: 4),
                                              if (hasComment) const Icon(Icons.comment, size: 12, color: Colors.blue),
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
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Удалить участок', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: plots.loading ? null : () => _confirmDelete(context, plot, plots),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
