import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';

/// Standalone example focusing on the granular marker callbacks:
/// - onMarkerAdded
/// - onMarkerFocused
///
/// Compare with main.dart which uses the unified onBodyPartTapped callback.
void main() => runApp(const MarkerCallbacksApp());

class MarkerCallbacksApp extends StatelessWidget {
  const MarkerCallbacksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marker Callback Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MarkerCallbacksHomePage(),
    );
  }
}

class MarkerCallbacksHomePage extends StatefulWidget {
  const MarkerCallbacksHomePage({super.key});

  @override
  State<MarkerCallbacksHomePage> createState() =>
      _MarkerCallbacksHomePageState();
}

class _MarkerCallbacksHomePageState extends State<MarkerCallbacksHomePage> {
  BodyParts _parts = const BodyParts();
  final Map<BodySide, List<BodyPartMarker>> _markersBySide = {
    for (final side in BodySide.values) side: <BodyPartMarker>[],
  };

  BodyPartTapDetails? _lastAdded;
  BodyPartTapDetails? _lastFocused;

  void _handleAdded(BodyPartTapDetails details) {
    _updateMarkers(details);
    setState(() => _lastAdded = details);
  }

  void _handleFocused(BodyPartTapDetails details) {
    // No list mutation here (focus only) but keep list in sync just in case.
    _updateMarkers(details);
    setState(() => _lastFocused = details);
  }

  void _updateMarkers(BodyPartTapDetails details) {
    final side = details.marker.side;
    _markersBySide[side] = List<BodyPartMarker>.of(details.markers);
  }

  int get _totalMarkers =>
      _markersBySide.values.fold<int>(0, (p, e) => p + e.length);

  @override
  Widget build(BuildContext context) {
    final lastAdded = _lastAdded;
    final lastFocused = _lastFocused;
    return Scaffold(
      appBar: AppBar(title: const Text('Marker Callback Demo')),
      body: Column(
        children: [
          Expanded(
            child: BodyPartSelectorTurnable(
              bodyParts: _parts,
              onSelectionUpdated: (p) => setState(() => _parts = p),
              onMarkerAdded: _handleAdded,
              onMarkerFocused: _handleFocused,
              initialMarkers: {
                for (final entry in _markersBySide.entries)
                  entry.key: entry.value,
              },
              highlightColor: Colors.indigo.shade200,
              markerColor: Colors.indigo,
              markerHasOutline: false,
              activeMarkerColor: Colors.orange,
              showRotateButton: true,
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total markers: $_totalMarkers'),
                const SizedBox(height: 8),
                if (lastAdded != null) ...[
                  Text('Last added: ${lastAdded.id} @ '
                      '(${lastAdded.marker.normalizedPosition.dx.toStringAsFixed(3)}, '
                      '${lastAdded.marker.normalizedPosition.dy.toStringAsFixed(3)}) '),
                ],
                if (lastFocused != null) ...[
                  Text('Last focused: ${lastFocused.id} '),
                ],
                if (lastAdded == null && lastFocused == null)
                  const Text('Tap to add a marker, tap existing to focus it.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
