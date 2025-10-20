import 'dart:math';

import 'package:body_part_selector/src/model/body_part_marker.dart';
import 'package:body_part_selector/src/model/body_parts.dart';
import 'package:body_part_selector/src/model/body_side.dart';
import 'package:body_part_selector/src/service/svg_copy/vector_drawable.dart';
import 'package:body_part_selector/src/service/svg_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:touchable/touchable.dart';

/// A widget that allows for selecting body parts.
class BodyPartSelector extends StatefulWidget {
  /// Creates a [BodyPartSelector].
  const BodyPartSelector({
    required this.bodyParts,
    required this.onSelectionUpdated,
    required this.side,
    this.mirrored = false,
    this.selectedColor,
    this.unselectedColor,
    this.selectedOutlineColor,
    this.unselectedOutlineColor,
    this.onBodyPartTapped,
    this.onMarkerAdded,
    this.onMarkerFocused,
    this.initialMarkers = const <BodyPartMarker>[],
    this.markerColor,
    this.markerOutlineColor,
    this.bodyFillColor,
    this.bodyOutlineColor,
    this.bodyOutlineWidth,
    this.highlightColor,
    this.markerRadius,
    this.markerHasOutline = true,
    this.activeMarkerColor,
    super.key,
  });

  /// {@template body_part_selector.body_parts}
  /// The current selection of body parts
  /// {@endtemplate}
  final BodyParts bodyParts;

  /// The side of the body to display.
  final BodySide side;

  /// {@template body_part_selector.on_selection_updated}
  /// Called when the selection of body parts is updated with the new selection.
  /// {@endtemplate}
  final void Function(BodyParts bodyParts)? onSelectionUpdated;

  /// Emits detailed information whenever a marker is added or removed by the
  /// user. Receives a [BodyPartTapDetails] object describing the action,
  /// updated selections and the current marker list.
  final ValueChanged<BodyPartTapDetails>? onBodyPartTapped;

  /// Called only when a new marker has been added as a direct result of a
  /// user tap. This is a convenience callback that filters
  /// [onBodyPartTapped] events with [BodyPartTapAction.markerAdded].
  final ValueChanged<BodyPartTapDetails>? onMarkerAdded;

  /// Called only when an existing marker was tapped (focused). This is a
  /// convenience callback that filters [onBodyPartTapped] events with
  /// [BodyPartTapAction.markerFocused].
  final ValueChanged<BodyPartTapDetails>? onMarkerFocused;

  /// {@template body_part_selector.mirrored}
  /// Whether the selection should be mirrored, or symmetric, such that when
  /// selecting the left arm for example, the right arm is selected as well.
  ///
  /// Defaults to false.
  /// {@endtemplate}
  final bool mirrored;

  /// {@template body_part_selector.selected_color}
  /// The color of the selected body parts.
  ///
  /// Defaults to [ThemeData.colorScheme.inversePrimary].
  /// {@endtemplate}
  final Color? selectedColor;

  /// {@template body_part_selector.unselected_color}
  /// The color of the unselected body parts.
  ///
  /// Defaults to [ThemeData.colorScheme.inverseSurface].
  /// {@endtemplate}
  final Color? unselectedColor;

  /// {@template body_part_selector.selected_outline_color}
  /// The color of the outline of the selected body parts.
  ///
  /// Defaults to [ThemeData.colorScheme.primary].
  /// {@endtemplate}
  final Color? selectedOutlineColor;

  /// {@template body_part_selector.unselected_outline_color}
  /// The color of the outline of the unselected body parts.
  ///
  /// Defaults to [ThemeData.colorScheme.onInverseSurface].
  /// {@endtemplate}
  final Color? unselectedOutlineColor;

  /// Markers that should be rendered when the widget is first built.
  final List<BodyPartMarker> initialMarkers;

  /// Fill color used for rendered markers.
  final Color? markerColor;

  /// Outline color used for rendered markers.
  final Color? markerOutlineColor;

  /// Whether the marker should render an outline.
  final bool markerHasOutline;

  /// Color used to highlight the marker that is currently focused.
  final Color? activeMarkerColor;

  /// Fill color of the body when not highlighted.
  final Color? bodyFillColor;

  /// Outline color of the body when not highlighted.
  final Color? bodyOutlineColor;

  /// Outline stroke width of the body.
  final double? bodyOutlineWidth;

  /// Highlight color applied when a body part is active/has markers.
  final Color? highlightColor;

  /// Radius of the rendered marker.
  final double? markerRadius;

  @override
  State<BodyPartSelector> createState() => _BodyPartSelectorState();
}

class _BodyPartSelectorState extends State<BodyPartSelector> {
  late List<BodyPartMarker> _markers;
  BodyPartMarker? _activeMarker;

  BodyParts get _bodyParts => widget.bodyParts;

  @override
  void initState() {
    super.initState();
    _markers = List<BodyPartMarker>.of(widget.initialMarkers);
  }

  @override
  void didUpdateWidget(covariant BodyPartSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.initialMarkers, widget.initialMarkers)) {
      _markers = List<BodyPartMarker>.of(widget.initialMarkers);
      if (_activeMarker != null && !_markers.contains(_activeMarker)) {
        _activeMarker = null;
      }
    }
  }

  void _handleTap(
    String id,
    Offset normalizedPosition,
    Rect viewBoxRect,
    double scale,
  ) {
    final selections = _bodyParts.toMap();
    if (!selections.containsKey(id)) {
      return;
    }

    const double minDistance = 1.0;
    final bool isTooClose = _markers.any((existing) {
      final dx = (existing.normalizedPosition.dx - normalizedPosition.dx) *
          viewBoxRect.width *
          scale;
      final dy = (existing.normalizedPosition.dy - normalizedPosition.dy) *
          viewBoxRect.height *
          scale;
      return sqrt(dx * dx + dy * dy) < minDistance;
    });
    if (isTooClose) {
      return;
    }

    final updated = _updateBodyPartsSelection(
      id,
      isSelected: true,
    );
    final updatedSelections = updated.toMap();
    final isSelected = updatedSelections[id] ?? false;
    final marker = BodyPartMarker(
      id: id,
      side: widget.side,
      layerSide: widget.side,
      normalizedPosition: normalizedPosition,
      timestamp: DateTime.now(),
    );

    setState(() {
      _markers = List<BodyPartMarker>.of(_markers)..add(marker);
      _activeMarker = marker;
    });

    widget.onSelectionUpdated?.call(updated);
    final details = BodyPartTapDetails(
      id: id,
      isSelected: isSelected,
      updatedBodyParts: updated,
      marker: marker,
      layerSide: marker.layerSide ?? widget.side,
      action: BodyPartTapAction.markerAdded,
      markers: _markers,
    );
    widget.onBodyPartTapped?.call(details);
    widget.onMarkerAdded?.call(details);
  }

  BodyParts _updateBodyPartsSelection(
    String id, {
    required bool isSelected,
  }) {
    final map = widget.bodyParts.toMap();
    if (!map.containsKey(id)) {
      return widget.bodyParts;
    }
    map[id] = isSelected;
    if (widget.mirrored) {
      final mirroredId = _resolveMirroredId(id);
      if (mirroredId != null && map.containsKey(mirroredId)) {
        map[mirroredId] = isSelected;
      }
    }
    return BodyParts.fromJson(map);
  }

  String? _resolveMirroredId(String id) {
    if (id.contains('left')) {
      return id.replaceAll('left', 'right');
    }
    if (id.contains('Left')) {
      return id.replaceAll('Left', 'Right');
    }
    if (id.contains('right')) {
      return id.replaceAll('right', 'left');
    }
    if (id.contains('Right')) {
      return id.replaceAll('Right', 'Left');
    }
    return null;
  }

  void _handleMarkerTap(
    BodyPartMarker marker,
    TapDownDetails _,
  ) {
    if (_activeMarker != marker) {
      setState(() => _activeMarker = marker);
    }
    final details = BodyPartTapDetails(
      id: marker.id,
      isSelected: widget.bodyParts.toMap()[marker.id] ?? false,
      updatedBodyParts: widget.bodyParts,
      marker: marker,
      layerSide: marker.layerSide ?? widget.side,
      action: BodyPartTapAction.markerFocused,
      markers: _markers,
    );
    widget.onBodyPartTapped?.call(details);
    widget.onMarkerFocused?.call(details);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = SvgService.instance.getSide(widget.side);
    return ValueListenableBuilder<DrawableRoot?>(
      valueListenable: notifier,
      builder: (context, value, _) {
        if (value == null) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        } else {
          return _buildBody(context, value);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, DrawableRoot drawable) {
    final colorScheme = Theme.of(context).colorScheme;
    final fillColor = widget.bodyFillColor ??
        widget.unselectedColor ??
        colorScheme.inverseSurface;
    final highlightColor = widget.highlightColor ??
        widget.selectedColor ??
        colorScheme.inversePrimary;
    final bodyOutlineColor = widget.bodyOutlineColor ??
        widget.unselectedOutlineColor ??
        colorScheme.onInverseSurface;
    final selectedOutlineColor =
        widget.selectedOutlineColor ?? bodyOutlineColor;
    final double outlineWidth =
        (widget.bodyOutlineWidth ?? 2.0).clamp(0.0, 10.0);
    final markerFill = widget.markerColor ?? colorScheme.tertiary;
    final markerOutline = widget.markerHasOutline
        ? widget.markerOutlineColor ?? colorScheme.onTertiary
        : null;
    final markerRadius = max(1.0, widget.markerRadius ?? 6.0);
    final activeMarkerColor = widget.activeMarkerColor ?? colorScheme.secondary;
    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      child: SizedBox.expand(
        key: ValueKey(widget.bodyParts),
        child: CanvasTouchDetector(
          gesturesToOverride: const [GestureType.onTapDown],
          builder: (context) => CustomPaint(
            painter: _BodyPainter(
              root: drawable,
              bodyParts: widget.bodyParts,
              onTap: _handleTap,
              context: context,
              selectedColor: highlightColor,
              unselectedColor: fillColor,
              selectedOutlineColor: selectedOutlineColor,
              unselectedOutlineColor: bodyOutlineColor,
              markers: _markers,
              markerColor: markerFill,
              markerOutlineColor: markerOutline,
              onMarkerTap: _handleMarkerTap,
              bodyOutlineWidth: outlineWidth,
              markerRadius: markerRadius,
              markerHasOutline: widget.markerHasOutline,
              activeMarker: _activeMarker,
              activeMarkerColor: activeMarkerColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.root,
    required this.bodyParts,
    required this.onTap,
    required this.context,
    required this.selectedColor,
    required this.unselectedColor,
    required this.unselectedOutlineColor,
    required this.selectedOutlineColor,
    required this.markers,
    required this.markerColor,
    required this.markerOutlineColor,
    required this.onMarkerTap,
    required this.bodyOutlineWidth,
    required this.markerRadius,
    required this.markerHasOutline,
    required this.activeMarker,
    required this.activeMarkerColor,
  });

  final DrawableRoot root;
  final BuildContext context;
  final void Function(String, Offset, Rect, double) onTap;
  final BodyParts bodyParts;
  final Color selectedColor;
  final Color unselectedColor;
  final Color unselectedOutlineColor;

  final Color selectedOutlineColor;
  final List<BodyPartMarker> markers;
  final Color markerColor;
  final Color? markerOutlineColor;
  final void Function(BodyPartMarker marker, TapDownDetails details)
      onMarkerTap;
  final double bodyOutlineWidth;
  final double markerRadius;
  final bool markerHasOutline;
  final BodyPartMarker? activeMarker;
  final Color activeMarkerColor;

  bool isSelected(String key) {
    final selections = bodyParts.toMap();
    if (selections.containsKey(key) && selections[key]!) {
      return true;
    }
    return markers.any((marker) => marker.id == key);
  }

  void drawBodyParts({
    required TouchyCanvas touchyCanvas,
    required Canvas plainCanvas,
    required Iterable<Drawable> drawables,
    required Matrix4 fittingMatrix,
    required double scale,
  }) {
    final inverseMatrix = Matrix4.inverted(fittingMatrix);
    final viewBoxRect = root.viewport.viewBoxRect;
    for (final element in drawables) {
      final id = element.id;
      if (id == null) {
        debugPrint('Found a drawable element without an ID. Skipping $element');
        continue;
      }
      touchyCanvas.drawPath(
        (element as DrawableShape).path.transform(fittingMatrix.storage),
        Paint()
          ..color = isSelected(id) ? selectedColor : unselectedColor
          ..style = PaintingStyle.fill,
        onTapDown: (details) {
          final localPosition = details.localPosition;
          final viewBoxPosition = MatrixUtils.transformPoint(
            inverseMatrix,
            localPosition,
          );
          final normalized = Offset(
            (viewBoxPosition.dx / viewBoxRect.width).clamp(0.0, 1.0),
            (viewBoxPosition.dy / viewBoxRect.height).clamp(0.0, 1.0),
          );
          onTap(id, normalized, viewBoxRect, scale);
        },
      );
      plainCanvas.drawPath(
        element.path.transform(fittingMatrix.storage),
        Paint()
          ..color =
              isSelected(id) ? selectedOutlineColor : unselectedOutlineColor
          ..strokeWidth = bodyOutlineWidth
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void drawMarkers({
    required TouchyCanvas touchyCanvas,
    required Canvas canvas,
    required Matrix4 fittingMatrix,
    required Size canvasSize,
  }) {
    final viewBoxRect = root.viewport.viewBoxRect;
    const double referenceSize = 320;
    const double baseMultiplier = 0.6;
    final double sizeFactor =
        (canvasSize.shortestSide / referenceSize).clamp(0.5, 2.5);
    final double scaledRadius = markerRadius * sizeFactor * baseMultiplier;
    final double scaledStroke =
        (2 * sizeFactor * baseMultiplier).clamp(1.0, 4.0);
    for (final marker in markers) {
      final viewBoxPoint = Offset(
        marker.normalizedPosition.dx * viewBoxRect.width,
        marker.normalizedPosition.dy * viewBoxRect.height,
      );
      final canvasPoint = MatrixUtils.transformPoint(
        fittingMatrix,
        viewBoxPoint,
      );
      final bool isActive = marker == activeMarker;
      final Color fillColor = isActive ? activeMarkerColor : markerColor;
      final Color? outlineColor = isActive
          ? (markerOutlineColor ?? activeMarkerColor)
          : markerOutlineColor;
      touchyCanvas.drawCircle(
        canvasPoint,
        scaledRadius,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill,
        onTapDown: (details) => onMarkerTap(marker, details),
      );
      if (markerHasOutline && outlineColor != null) {
        canvas.drawCircle(
          canvasPoint,
          scaledRadius,
          Paint()
            ..color = outlineColor
            ..strokeWidth = scaledStroke
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size != root.viewport.viewBoxRect.size) {
      final double scale = min(
        size.width / root.viewport.viewBoxRect.width,
        size.height / root.viewport.viewBoxRect.height,
      );
      final scaledHalfViewBoxSize =
          root.viewport.viewBoxRect.size * scale / 2.0;
      final halfDesiredSize = size / 2.0;
      final shift = Offset(
        halfDesiredSize.width - scaledHalfViewBoxSize.width,
        halfDesiredSize.height - scaledHalfViewBoxSize.height,
      );

      final bodyPartsCanvas = TouchyCanvas(context, canvas);

      final fittingMatrix = Matrix4.identity()
        ..translate(shift.dx, shift.dy)
        ..scale(scale);

      final drawables =
          root.children.where((element) => element.hasDrawableContent);

      drawBodyParts(
        touchyCanvas: bodyPartsCanvas,
        plainCanvas: canvas,
        drawables: drawables,
        fittingMatrix: fittingMatrix,
        scale: scale,
      );

      drawMarkers(
        touchyCanvas: bodyPartsCanvas,
        canvas: canvas,
        fittingMatrix: fittingMatrix,
        canvasSize: size,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
