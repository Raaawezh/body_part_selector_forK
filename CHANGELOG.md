## 0.3.1

Patch feature release (non-breaking).

### Added
- New convenience callbacks `onMarkerAdded` and `onMarkerFocused` in both
	`BodyPartSelector` and `BodyPartSelectorTurnable`. These emit the same
	`BodyPartTapDetails` payload as `onBodyPartTapped` but are filtered to only
	marker creation and existing-marker tap (focus) events respectively. This
	simplifies integrations (e.g. FlutterFlow) where branching on
	`BodyPartTapAction` might be less ergonomic.

### Notes
- Existing `onBodyPartTapped` API is unchanged; no breaking changes.
- Internally, the callbacks are dispatched after marker state updates ensuring
	the `markers` list in the payload reflects the latest state.

## 0.3.0

Minor feature release (no breaking changes).

### Features
- Added `BodyPartId` enum (type-safe identifiers for every selectable body part; names match SVG `id` attributes and `BodyParts` fields).
- Added `BodyParts.fromIds(Iterable<BodyPartId>)` factory to build a selection from enum values.
- Added `BodyParts.selectedIds` getter returning a `List<BodyPartId>` of all currently selected parts.
- Added extension `BodyPartsToggleX` with convenience methods:
	- `toggle(BodyPartId id, {bool mirror = false})`
	- `toggleMany(Iterable<BodyPartId> ids, {bool mirror = false})`
- Introduced marker system (body part pin support):
	- `BodyPartMarker` model with normalized position, side, layerSide and timestamp.
	- `initialMarkers` parameter (list) for `BodyPartSelector`.
	- `initialMarkers` parameter (map `Map<BodySide, List<BodyPartMarker>>`) for `BodyPartSelectorTurnable`.
	- Automatic pin rendering & active marker highlighting.
- Added rich tap callback `onBodyPartTapped` (both widgets) returning `BodyPartTapDetails` (id, isSelected, updatedBodyParts, marker, layerSide, action, markers list).
- Extended visual customization: `markerColor`, `markerOutlineColor`, `markerRadius`, `markerHasOutline`, `activeMarkerColor`, `bodyFillColor`, `bodyOutlineColor`, `bodyOutlineWidth`, `highlightColor`, `selectedColor`, `unselectedColor`, `selectedOutlineColor`, `unselectedOutlineColor`.
- Rotation stage enhancements: `rotateRightTrigger`, `onRotateRequested`, `rotateButtonIcon`, `showRotateButton`, `labelData`.
- Library export updated to include all new public symbols.

### Documentation
- Rewritten and expanded README: sections for tap & marker handling, existing marker injection, callback payload structure, constructor parameter reference, type-safe identifiers, FlutterFlow integration, and asset attribution.
- Added usage examples for enum-based selection and restoration from stored strings.

### Tests
- Added enum consistency tests ensuring all enum names match `BodyParts` JSON keys.
- Added roundtrip tests for `fromIds` / `selectedIds`.
- Added extension tests (`toggle`, `toggleMany`, mirrored toggling).

### Chore
- Public API surface expanded with explicit exports (`body_part_selector.dart`).
- General README style alignment with new features.

## 0.2.0

> Note: This release has breaking changes.

 - **FEAT**: added `animateToSide` method to `RotationStageController`.
 - **BREAKING** **FEAT**: rotation stage handle are not uppercase by default anymore.

## 0.1.0

> Note: This release has breaking changes.

 - **FIX**: fixed broken toJson().
 - **DOCS**(rotation_stage): documented all public classes.
 - **BREAKING** **FIX**: removed `labels` parameter in `RotationStage`.
 - **BREAKING** **BUILD**: bump flutter version.

## 0.0.3
* bump rotation_stage version
* allow for custom labels

## 0.0.2
* added demo GIF to README

## 0.0.1
* Initial Release
