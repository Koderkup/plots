import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plots_provider.dart';
import '../models/plot.dart';

/// Экран создания участка (перенос app/create-plot.tsx).
class CreatePlotScreen extends StatefulWidget {
  const CreatePlotScreen({super.key});

  @override
  State<CreatePlotScreen> createState() => _CreatePlotScreenState();
}

class _CreatePlotScreenState extends State<CreatePlotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  late PlotParams _params;

  @override
  void initState() {
    super.initState();
    _params = PlotParams(
      name: '', entrances: 2, floors: 5, apartmentsPerFloor: 4,
      startNumber: 1, numberingScheme: 'sequential',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _update(PlotParams Function(PlotParams) build) {
    setState(() => _params = build(_params));
  }

  Widget _numberInput({
    required String label,
    required int value,
    required void Function(int) onChanged,
    int min = 1,
    int max = 100,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            _numBtn(Icons.remove, () => onChanged((value - 1).clamp(min, max)), value <= min),
            SizedBox(
              width: 70,
              child: TextFormField(
                initialValue: value.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  isCollapsed: true,
                ),
                onChanged: (t) => onChanged((int.tryParse(t) ?? min).clamp(min, max)),
              ),
            ),
            _numBtn(Icons.add, () => onChanged((value + 1).clamp(min, max)), value >= max),
          ],
        ),
        const SizedBox(height: 4),
        Text('от $min до $max', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _numBtn(IconData icon, VoidCallback onPressed, bool disabled) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: disabled ? Colors.grey.shade200 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IconButton(
        icon: Icon(icon, color: disabled ? Colors.grey : Colors.blue, size: 20),
        onPressed: disabled ? null : onPressed,
        constraints: const BoxConstraints(), padding: EdgeInsets.zero,
      ),
    );
  }

  String _previewNumbers(int entrance) {
    final p = _params;
    final res = <int>[];
    for (int f = 1; f <= p.floors; f++) {
      for (int a = 1; a <= p.apartmentsPerFloor; a++) {
        int n;
        if (p.numberingScheme == 'sequential') {
          final before = (entrance - 1) * p.floors * p.apartmentsPerFloor +
              (f - 1) * p.apartmentsPerFloor + (a - 1);
          n = p.startNumber + before;
        } else {
          n = p.startNumber + (f - 1) * p.apartmentsPerFloor + (a - 1);
        }
        res.add(n);
      }
    }
    return '${res.take(4).map((e) => e.toString()).join(', ')}…';
  }
  Future<void> _create() async {
    final p = _params;
    if (p.name.trim().isEmpty) { _show('Введите название участка'); return; }
    if (p.entrances < 1 || p.entrances > 10) { _show('Количество подъездов должно быть от 1 до 10'); return; }
    if (p.floors < 1 || p.floors > 25) { _show('Количество этажей должно быть от 1 до 25'); return; }
    if (p.apartmentsPerFloor < 1 || p.apartmentsPerFloor > 10) { _show('Количество квартир на этаже должно быть от 1 до 10'); return; }
    if (p.startNumber < 1 || p.startNumber > 1000) { _show('Начальный номер должен быть от 1 до 1000'); return; }

    final provider = context.read<PlotsProvider>();
    final navigator = Navigator.of(context);
    final ok = await provider.addPlot(p);
    if (ok && mounted) {
      navigator.pop();
    } else if (mounted) {
      _show(provider.error ?? 'Ошибка создания');
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final p = _params;
    final plots = context.watch<PlotsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Создание участка')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Название участка', border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите название' : null,
              onSaved: (v) => _update((_) => PlotParams(
                    name: v ?? '', entrances: p.entrances, floors: p.floors,
                    apartmentsPerFloor: p.apartmentsPerFloor,
                    startNumber: p.startNumber, numberingScheme: p.numberingScheme,
                  )),
            ),
            const SizedBox(height: 20),
            _numberInput(label: 'Подъезды', value: p.entrances,
                onChanged: (v) => _update((_) => PlotParams(
                      name: p.name, entrances: v, floors: p.floors,
                      apartmentsPerFloor: p.apartmentsPerFloor,
                      startNumber: p.startNumber, numberingScheme: p.numberingScheme,
                    )), min: 1, max: 10),
            const SizedBox(height: 16),
            _numberInput(label: 'Этажей', value: p.floors,
                onChanged: (v) => _update((_) => PlotParams(
                      name: p.name, entrances: p.entrances, floors: v,
                      apartmentsPerFloor: p.apartmentsPerFloor,
                      startNumber: p.startNumber, numberingScheme: p.numberingScheme,
                    )), min: 1, max: 25),
            const SizedBox(height: 16),
            _numberInput(label: 'Квартир на этаже', value: p.apartmentsPerFloor,
                onChanged: (v) => _update((_) => PlotParams(
                      name: p.name, entrances: p.entrances, floors: p.floors,
                      apartmentsPerFloor: v, startNumber: p.startNumber,
                      numberingScheme: p.numberingScheme,
                    )), min: 1, max: 10),
            const SizedBox(height: 16),
            _numberInput(label: 'Начальный номер', value: p.startNumber,
                onChanged: (v) => _update((_) => PlotParams(
                      name: p.name, entrances: p.entrances, floors: p.floors,
                      apartmentsPerFloor: p.apartmentsPerFloor,
                      startNumber: v, numberingScheme: p.numberingScheme,
                    )), min: 1, max: 1000),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: p.numberingScheme,
              decoration: const InputDecoration(
                labelText: 'Схема нумерации', border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'sequential', child: Text('Последовательная')),
                DropdownMenuItem(value: 'byEntrance', child: Text('По подъездам')),
              ],
              onChanged: (v) => _update((_) => PlotParams(
                    name: p.name, entrances: p.entrances, floors: p.floors,
                    apartmentsPerFloor: p.apartmentsPerFloor,
                    startNumber: p.startNumber, numberingScheme: v ?? 'sequential',
                  )),
            ),
            const SizedBox(height: 24),
            const Text('Предпросмотр номеров', style: TextStyle(fontWeight: FontWeight.bold)),
            for (int e = 1; e <= p.entrances && e <= 2; e++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('$e подъезд: ${_previewNumbers(e)}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: plots.loading ? null : _create,
                child: const Text('Создать участок',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}