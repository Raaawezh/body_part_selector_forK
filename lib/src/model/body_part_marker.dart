import 'dart:collection';
import 'dart:ui';

import 'package:body_part_selector/src/model/body_parts.dart';
import 'package:body_part_selector/src/model/body_side.dart';
import 'package:flutter/foundation.dart';

/// Describes a single marker placed on the body illustration.
@immutable
class BodyPartMarker {
  /// Creates a new [BodyPartMarker].
  const BodyPartMarker({
    required this.id,
    required this.side,
    required this.normalizedPosition,
    required this.timestamp,
    this.layerSide,
  });

  /// Identifier of the tapped body segment (e.g. `leftUpperArm`).
  final String id;

  /// Side of the body that was visible while the marker was placed.
  final BodySide side;

  /// The current viewing layer (front/left/back/right) when the marker was
  /// created. This can differ from [side] in mirrored setups where tapping the
  /// right arm while viewing the left side still toggles the mirrored part.
  final BodySide? layerSide;

  /// Tap location normalised to the SVG view-box (0..1 on both axes).
  final Offset normalizedPosition;

  /// Timestamp of when the marker was created.
  final DateTime timestamp;

  /// Returns a JSON representation of the marker for persistence.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'side': describeEnum(side),
        if (layerSide != null) 'layerSide': describeEnum(layerSide!),
        'x': normalizedPosition.dx,
        'y': normalizedPosition.dy,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Creates a copy of the marker with updated fields.
  BodyPartMarker copyWith({
    String? id,
    BodySide? side,
    BodySide? layerSide,
    Offset? normalizedPosition,
    DateTime? timestamp,
  }) {
    return BodyPartMarker(
      id: id ?? this.id,
      side: side ?? this.side,
      layerSide: layerSide ?? this.layerSide,
      normalizedPosition: normalizedPosition ?? this.normalizedPosition,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BodyPartMarker &&
        other.id == id &&
        other.side == side &&
        other.layerSide == layerSide &&
        other.normalizedPosition == normalizedPosition &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(
        id,
        side,
        layerSide,
        normalizedPosition.dx,
        normalizedPosition.dy,
        timestamp,
      );

  @override
  String toString() =>
      'BodyPartMarker(id: $id, side: $side, position: $normalizedPosition)';
}

/// Indicates what happened during a body part tap interaction.
enum BodyPartTapAction {
  /// A marker was added to the tapped body part.
  markerAdded,

  /// A marker was removed by an external flow (not emitted by default).
  markerRemoved,

  /// An existing marker was tapped / focused without immediate mutation.
  markerFocused,
}

/// Detailed context passed through the `onBodyPartTapped` callback.
class BodyPartTapDetails {
  /// Creates a new [BodyPartTapDetails].
  BodyPartTapDetails({
    required this.id,
    required this.isSelected,
    required this.updatedBodyParts,
    required this.marker,
    required this.layerSide,
    required this.action,
    required Iterable<BodyPartMarker> markers,
  }) : markers = UnmodifiableListView(markers);

  /// Identifier of the tapped body segment.
  final String id;

  /// Whether the tapped body segment is selected after the tap.
  final bool isSelected;

  /// Snapshot of all selections after the tap.
  final BodyParts updatedBodyParts;

  /// Marker created for this tap event.
  final BodyPartMarker marker;

  /// Viewing side (front/left/back/right) active at the time of the tap.
  final BodySide layerSide;

  /// All markers currently placed on this side.
  final UnmodifiableListView<BodyPartMarker> markers;

  /// What kind of action produced this callback.
  final BodyPartTapAction action;
}
