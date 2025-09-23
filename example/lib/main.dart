import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Body Part Selector',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BodyParts _bodyParts = const BodyParts();
  final Map<BodySide, List<BodyPartMarker>> _markersBySide = {
    for (final side in BodySide.values) side: <BodyPartMarker>[],
  };
  BodyPartTapDetails? _lastTap;
  int _rotateTrigger = 0;

  Map<BodySide, List<BodyPartMarker>> get _initialMarkers => {
        for (final entry in _markersBySide.entries)
          entry.key: List<BodyPartMarker>.of(entry.value),
      };

  void _onBodyPartTapped(BodyPartTapDetails details) {
    final side = details.marker.side;
    setState(() {
      _markersBySide[side] = List<BodyPartMarker>.of(details.markers);
      _lastTap = details;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BodyPartSelectorTurnable(
                bodyParts: _bodyParts,
                onSelectionUpdated: (p) => setState(() => _bodyParts = p),
                onBodyPartTapped: _onBodyPartTapped,
                rotateRightTrigger: _rotateTrigger,
                labelData: const RotationStageLabelData(
                  front: 'Front',
                  left: 'Left',
                  right: 'Right',
                  back: 'Back',
                ),
                initialMarkers: _initialMarkers,
                bodyFillColor: Colors.grey.shade200,
                bodyOutlineColor: Colors.grey.shade600,
                bodyOutlineWidth: 1.5,
                highlightColor: Colors.purple.shade200,
                markerColor: Colors.purple,
                markerRadius: 6,
                markerHasOutline: false,
                activeMarkerColor: Colors.deepOrange,
                showRotateButton: false,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _lastTap == null
                  ? const Text('Tap a body part to place a marker.\n\n')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'Last action: ${_lastTap!.action.name} on ${_lastTap!.marker.side.name} (${_lastTap!.id}) while viewing ${_lastTap!.layerSide.name}'),
                        Text(
                          'Normalized position: '
                          '(${_lastTap!.marker.normalizedPosition.dx.toStringAsFixed(3)}, '
                          '${_lastTap!.marker.normalizedPosition.dy.toStringAsFixed(3)})',
                        ),
                        Text('Markers placed: '
                            '${_markersBySide.values.fold<int>(0, (prev, list) => prev + list.length)}'),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _rotateTrigger++),
                icon: const Icon(Icons.rotate_right),
                label: const Text('Rotate right'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
