import 'package:flutter/material.dart';

import 'home_place.dart';
import 'location_service.dart';

/// Imposta dove si trova casa: scrivendo l'indirizzo e/o salvando
/// la posizione attuale quando si è a casa.
class HomeSetupScreen extends StatefulWidget {
  const HomeSetupScreen({
    super.key,
    required this.homeStore,
    required this.location,
  });

  final HomeStore homeStore;
  final LocationService location;

  @override
  State<HomeSetupScreen> createState() => _HomeSetupScreenState();
}

class _HomeSetupScreenState extends State<HomeSetupScreen> {
  late final TextEditingController _address;
  GeoPoint? _point;
  bool _locating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final home = widget.homeStore.home;
    _address = TextEditingController(text: home?.address ?? '');
    _point = home?.point;
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _useCurrentPosition() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      final point = await widget.location.currentPosition();
      setState(() => _point = point);
    } on LocationException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    final address = _address.text.trim();
    if (address.isEmpty && _point == null) {
      setState(
        () =>
            _error = "Scrivi l'indirizzo oppure tocca \"Sono a casa adesso\".",
      );
      return;
    }
    await widget.homeStore.save(HomePlace(address: address, point: _point));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('La mia casa')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Indirizzo di casa',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _address,
            style: const TextStyle(fontSize: 22),
            decoration: const InputDecoration(
              hintText: 'Es. Via Roma 12, Milano',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            maxLines: 2,
            minLines: 1,
          ),
          const SizedBox(height: 32),
          Text(
            'Oppure, se sei a casa adesso:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _locating ? null : _useCurrentPosition,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              textStyle: const TextStyle(fontSize: 20),
            ),
            icon: _locating
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Icon(Icons.my_location, size: 28),
            label: Text(_locating ? 'Cerco dove sei...' : 'Sono a casa adesso'),
          ),
          if (_point != null)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF2B8A3E), size: 32),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Posizione di casa salvata',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'Salvare la posizione da casa è il modo più preciso, e serve '
            'anche per sapere quanto sei lontano.',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save, size: 32),
            label: const Text('Salva'),
          ),
        ),
      ),
    );
  }
}
