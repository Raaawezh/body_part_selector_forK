import 'package:body_part_selector/src/body_part_selector.dart';
import 'package:body_part_selector/src/model/body_part_marker.dart';
import 'package:body_part_selector/src/model/body_parts.dart';
import 'package:body_part_selector/src/model/body_side.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rotation_stage/rotation_stage.dart';

export 'package:rotation_stage/rotation_stage.dart';

/// A widget that allows for selecting body parts on a turnable body.
///
/// The widget wraps [RotationStage] and exposes a clockwise rotate button as
/// well as a trigger that can be toggled externally (e.g. from FlutterFlow).
class BodyPartSelectorTurnable extends StatefulWidget {
  /// Creates a [BodyPartSelectorTurnable].
  const BodyPartSelectorTurnable({
    required this.bodyParts,
    super.key,
    this.onSelectionUpdated,
    this.onBodyPartTapped,
    this.onMarkerAdded,
    this.onMarkerFocused,
    this.onRotateRequested,
    this.mirrored = false,
    this.selectedColor,
    this.unselectedColor,
    this.selectedOutlineColor,
    this.unselectedOutlineColor,
    this.padding = EdgeInsets.zero,
    this.labelData,
    this.initialMarkers = const <BodySide, List<BodyPartMarker>>{},
    this.markerColor,
    this.markerOutlineColor,
    this.bodyFillColor,
    this.bodyOutlineColor,
    this.bodyOutlineWidth,
    this.highlightColor,
    this.markerRadius,
    this.markerHasOutline = true,
    this.activeMarkerColor,
    this.rotateRightTrigger = 0,
    this.rotateButtonIcon,
    this.showRotateButton = true,
  });

  /// {@macro body_part_selector.body_parts}
  final BodyParts bodyParts;

  /// {@macro body_part_selector.on_selection_updated}
  final ValueChanged<BodyParts>? onSelectionUpdated;

  /// Emits detailed information whenever a body part on any side is tapped.
  final ValueChanged<BodyPartTapDetails>? onBodyPartTapped;

  /// Convenience callback fired only when a marker is added on any side.
  final ValueChanged<BodyPartTapDetails>? onMarkerAdded;

  /// Convenience callback fired only when an existing marker is tapped on any side.
  final ValueChanged<BodyPartTapDetails>? onMarkerFocused;

  /// Invoked right before the widget rotates clockwise (either via the built-in
  /// button or the external trigger). Use this to perform side effects in the
  /// host environment (e.g. FlutterFlow actions).
  final Future<void> Function()? onRotateRequested;

  /// {@macro body_part_selector.mirrored}
  final bool mirrored;

  /// {@macro body_part_selector.selected_color}
  final Color? selectedColor;

  /// {@macro body_part_selector.unselected_color}
  final Color? unselectedColor;

  /// {@macro body_part_selector.selected_outline_color}
  final Color? selectedOutlineColor;

  /// {@macro body_part_selector.unselected_outline_color}
  final Color? unselectedOutlineColor;

  /// The padding around the rendered body (outside the widget).
  final EdgeInsets padding;

  /// The labels for the sides of the [RotationStage].
  final RotationStageLabelData? labelData;

  /// Pre-populated markers keyed by the corresponding [BodySide].
  final Map<BodySide, List<BodyPartMarker>> initialMarkers;

  /// Fill color used for rendered markers.
  final Color? markerColor;

  /// Outline color used for rendered markers.
  final Color? markerOutlineColor;

  /// Fill color of the body when not highlighted.
  final Color? bodyFillColor;

  /// Outline color of the body when not highlighted.
  final Color? bodyOutlineColor;

  /// Outline stroke width of the body.
  final double? bodyOutlineWidth;

  /// Highlight color applied when a body part is active/has markers.
  final Color? highlightColor;

  /// Radius of rendered markers.
  final double? markerRadius;

  /// Whether markers should render an outline.
  final bool markerHasOutline;

  /// Color used to highlight the marker that is currently focused.
  final Color? activeMarkerColor;

  /// Increments every time an external rotation should occur.
  ///
  /// Changing the value (e.g. ++rotateRightTrigger) rotates the stage one step
  /// clockwise.
  final int rotateRightTrigger;

  /// Custom icon shown inside the rotation button.
  final Widget? rotateButtonIcon;

  /// Whether the rotation button should be rendered.
  final bool showRotateButton;

  @override
  State<BodyPartSelectorTurnable> createState() =>
      _BodyPartSelectorTurnableState();
}

class _BodyPartSelectorTurnableState extends State<BodyPartSelectorTurnable> {
  static const double _kDefaultBarHeight = 64;

  late final RotationStageController _stageController;
  late int _lastRotateTrigger;

  @override
  void initState() {
    super.initState();
    _stageController = RotationStageController();
    _lastRotateTrigger = widget.rotateRightTrigger;
  }

  @override
  void didUpdateWidget(covariant BodyPartSelectorTurnable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rotateRightTrigger != _lastRotateTrigger) {
      _lastRotateTrigger = widget.rotateRightTrigger;
      _rotateRight();
    }
  }

  @override
  void dispose() {
    _stageController.dispose();
    super.dispose();
  }

  Future<void> _rotateRight() async {
    if (!mounted) return;
    await widget.onRotateRequested?.call();
    _stageController.animateToPage(
      _stageController.value.round() + 1,
      duration: kThemeAnimationDuration,
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labelData ?? RotationStageLabelData.english;
    final child = Stack(
      fit: StackFit.expand,
      children: [
        RotationStage(
          controller: _stageController,
          contentBuilder: (index, stageSide, page) {
            final mappedSide = stageSide.toBodySide();
            final markersForSide =
                widget.initialMarkers[mappedSide] ?? const <BodyPartMarker>[];
            return Padding(
              padding: const EdgeInsets.all(16),
              child: BodyPartSelector(
                side: mappedSide,
                bodyParts: widget.bodyParts,
                onSelectionUpdated: widget.onSelectionUpdated,
                onBodyPartTapped: widget.onBodyPartTapped,
                onMarkerAdded: widget.onMarkerAdded,
                onMarkerFocused: widget.onMarkerFocused,
                mirrored: widget.mirrored,
                selectedColor: widget.selectedColor,
                unselectedColor: widget.unselectedColor,
                selectedOutlineColor: widget.selectedOutlineColor,
                unselectedOutlineColor: widget.unselectedOutlineColor,
                initialMarkers: markersForSide,
                markerColor: widget.markerColor,
                markerOutlineColor: widget.markerOutlineColor,
                bodyFillColor: widget.bodyFillColor,
                bodyOutlineColor: widget.bodyOutlineColor,
                bodyOutlineWidth: widget.bodyOutlineWidth,
                highlightColor: widget.highlightColor,
                markerRadius: widget.markerRadius,
                markerHasOutline: widget.markerHasOutline,
                activeMarkerColor: widget.activeMarkerColor,
              ),
            );
          },
        ),
        if (widget.showRotateButton)
          Positioned(
            right: 24,
            bottom: 24 + _kDefaultBarHeight,
            child: _RotationButton(
              icon: widget.rotateButtonIcon ??
                  SvgPicture.asset(
                    'packages/body_part_selector/assets/refresh-svgrepo-com.svg',
                    width: 20,
                    height: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
              onPressed: _rotateRight,
            ),
          ),
      ],
    );

    return RotationStageLabels(
      data: labels,
      child: Padding(
        padding: widget.padding,
        child: child,
      ),
    );
  }
}

class _RotationButton extends StatelessWidget {
  const _RotationButton({
    required this.icon,
    required this.onPressed,
  });

  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primary,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}

extension on RotationStageSide {
  BodySide toBodySide() {
    return map(
      front: BodySide.front,
      left: BodySide.left,
      back: BodySide.back,
      right: BodySide.right,
    );
  }
}
