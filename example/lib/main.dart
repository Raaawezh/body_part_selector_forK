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
  // --- state fields (keep these) ---
  BodyParts _bodyParts = const BodyParts();
  final Map<BodySide, List<BodyPartMarker>> _markersBySide = {
    for (final side in BodySide.values) side: <BodyPartMarker>[],
  };
  BodyPartTapDetails? _lastTap;
  int _rotateTrigger = 0;
  BodySide _currentSide = BodySide.front; // track which side is shown

  Map<BodySide, List<BodyPartMarker>> get _initialMarkers => {
        for (final entry in _markersBySide.entries)
          entry.key: List.of(entry.value),
      };

// --- updated tap handler ---
  void _onBodyPartTapped(BodyPartTapDetails details) {
    final side = details.marker.side;
    final tappedMarker = details.marker;
    final tappedId = details.id;

    setState(() {
      final markers = List<BodyPartMarker>.of(_markersBySide[side]!);

      // Check if marker already exists (means it's a double-tap)
      final existingIndex = markers.indexWhere((m) => m.id == tappedMarker.id);

      if (existingIndex != -1) {
        // 👇 Double-tap: remove marker + remove highlight (force deselect)
        markers.removeAt(existingIndex);

        // Explicitly unselect the body part in the BodyParts state
      } else { 
        // 👇 Normal tap: add marker + highlight the part
        markers.add(tappedMarker);
      }
      _bodyParts = _bodyParts.withToggledId(
        tappedId,
      );
      _markersBySide[side] = markers;
      _lastTap = details;
    });
  }

// --- updated rotate handler ---
  void _rotateRight() {
    setState(() {
      _rotateTrigger++;

      // rotation order: front -> right -> back -> left -> front
      final next = {
        BodySide.front: BodySide.right,
        BodySide.right: BodySide.back,
        BodySide.back: BodySide.left,
        BodySide.left: BodySide.front,
      };

      final newSide = next[_currentSide] ?? BodySide.front;

      // If the new side has never been tapped (no markers),
      // clear markers/highlights from the sides that haven't been tapped.
      // This prevents front markers from automatically mirroring to back
      // unless the user tapped the back side previously.
      if (_markersBySide[newSide]?.isEmpty ?? true) {
        for (final side in BodySide.values) {
          if (side != newSide && (_markersBySide[side]?.isEmpty ?? true)) {
            // only clear sides that are empty OR you can clear all others:
            _markersBySide[side] = [];
          }
        }
      }
      _currentSide = newSide;
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
                onPressed: _rotateRight,
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
