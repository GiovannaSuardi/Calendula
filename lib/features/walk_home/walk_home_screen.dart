import 'package:flutter/material.dart';

import 'home_place.dart';
import 'home_setup_screen.dart';
import 'location_service.dart';

/// Un pulsante grande che apre Google Maps con il percorso a piedi verso casa.
class WalkHomeScreen extends StatefulWidget {
  const WalkHomeScreen({
    super.key,
    required this.homeStore,
    this.location = const GeolocatorLocationService(),
    this.openUrl = openExternally,
  });

  final HomeStore homeStore;
  final LocationService location;
  final UrlOpener openUrl;

  @override
  State<WalkHomeScreen> createState() => _WalkHomeScreenState();
}

class _WalkHomeScreenState extends State<WalkHomeScreen> {
  bool _locating = false;
  String? _distance;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _updateDistance();
  }

  /// Calcola quanto si è lontani da casa (solo se casa ha una posizione GPS).
  Future<void> _updateDistance() async {
    final homePoint = widget.homeStore.home?.point;
    if (homePoint == null) return;
    setState(() {
      _locating = true;
      _distance = null;
      _locationError = null;
    });
    try {
      final here = await widget.location.currentPosition();
      final meters = here.distanceTo(homePoint);
      if (!mounted) return;
      setState(
        () => _distance = meters < 50
            ? 'Sei a casa!'
            : 'Sei a ${describeDistance(meters)} da casa',
      );
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() => _locationError = e.message);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _goHome(HomePlace home) async {
    final opened = await widget.openUrl(home.walkingDirectionsUrl());
    if (opened || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Non riesco ad aprire le mappe'),
        content: const Text(
          'Controlla che sul telefono ci sia Google Maps '
          'e che internet sia acceso.',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ho capito'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomeSetupScreen(
          homeStore: widget.homeStore,
          location: widget.location,
        ),
      ),
    );
    _updateDistance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Torna a casa')),
      body: ListenableBuilder(
        listenable: widget.homeStore,
        builder: (context, _) {
          final home = widget.homeStore.home;
          return home == null ? _buildNoHome(context) : _buildHome(home);
        },
      ),
    );
  }

  Widget _buildNoHome(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.home, size: 96, color: Color(0xFF2B8A3E)),
        const SizedBox(height: 16),
        Text(
          'Prima dimmi dove abiti.\n'
          'Lo farai una volta sola.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _openSetup,
          icon: const Icon(Icons.edit_location_alt, size: 32),
          label: const Text('Imposta la mia casa'),
        ),
      ],
    );
  }

  Widget _buildHome(HomePlace home) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.home, size: 48),
            title: const Text(
              'Casa mia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              home.address.isNotEmpty
                  ? home.address
                  : 'Posizione salvata sulla mappa',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_locating)
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              SizedBox(width: 12),
              Text('Cerco dove sei...', style: TextStyle(fontSize: 20)),
            ],
          ),
        if (_distance != null)
          Text(
            _distance!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        if (_locationError != null)
          Text(
            _locationError!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => _goHome(home),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 96),
            backgroundColor: const Color(0xFF2B8A3E),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          icon: const Icon(Icons.directions_walk, size: 48),
          label: const Text('Portami a casa'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Si aprirà la mappa con la strada a piedi.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: _openSetup,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            textStyle: const TextStyle(fontSize: 20),
          ),
          icon: const Icon(Icons.edit_location_alt, size: 28),
          label: const Text('Cambia la mia casa'),
        ),
      ],
    );
  }
}
