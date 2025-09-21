# Body Part Selector
A simple and beautiful selector for body parts.

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![melos](https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square)](https://github.com/invertase/melos)

![Demo GIF](./demo.gif)


## Installation 

**! In order to start using Body Part Selector you must have the [Dart SDK][dart_install_link] installed on your machine.**

Install via `dart pub add`:

```sh
dart pub add body_part_selector
```

## Usage
There are two widgets: `BodyPartSelector` and `BodyPartSelectorTurnable`, the latter can be seen in the GIF.

Check out the example file for a simple usage pattern.

### Listening to taps & markers

`BodyPartSelector` now exposes an `onBodyPartTapped` callback that provides
`BodyPartTapDetails` with the tapped body part identifier, the updated
`BodyParts` selection, the action (`markerAdded`/`markerFocused`), and a
`BodyPartMarker` describing the tap (including normalised coordinates). The
widget stores markers internally, renders them as pins (highlighting the body
segment as long as at least one marker is present), and returns the full list
through the callback so that you can persist the data and restore it later (for
example in FlutterFlow). Tapping an existing pin does not trigger any built-in
menu; instead, the callback is fired with `markerFocused` so you can implement
custom actions (e.g. deletion or editing) in your own UI.

You can fully theme the selector: customise body fill/highlight colors, outline
color and width, marker size/colour, focused-marker color, or even disable
marker outlines entirely. Pins enforce a 1 px spacing inside the SVG view box,
so every stored marker keeps unique coordinates. `BodyPartTapDetails` also
reports the active perspective (`layerSide`), letting you distinguish front,
back, left or right taps immediately.

#### Callback payload

The callback receives a `BodyPartTapDetails` instance:

```
class BodyPartTapDetails {
  final String id; // segment identifier (e.g. leftUpperArm)
  final bool isSelected; // whether the segment is selected after the tap
  final BodyParts updatedBodyParts; // snapshot of the entire selection
  final BodyPartMarker marker; // marker that triggered the callback
  final BodySide layerSide; // perspective (front/left/back/right) during tap
  final BodyPartTapAction action; // markerAdded, markerFocused (or markerRemoved)
  final List<BodyPartMarker> markers; // markers currently rendered for this side
}

class BodyPartMarker {
  final String id; // body segment associated with the marker
  final BodySide side; // anatomical side inferred from the id
  final BodySide? layerSide; // perspective in which the marker was created
  final Offset normalizedPosition; // coordinates (0..1) inside the SVG view box
  final DateTime timestamp; // marker creation timestamp
}
```

The `markers` list contains all pins currently visible for the active
perspective (in insertion order), ready to be serialised or persisted.

#### Providing existing markers

To display markers fetched from a database, convert your stored records to
`BodyPartMarker` instances and pass them through `initialMarkers`:

```
final markers = rows.map((json) => BodyPartMarker(
  id: json['id'] as String,
  side: BodySide.values.byName(json['side'] as String),
  layerSide: json['layerSide'] != null
      ? BodySide.values.byName(json['layerSide'] as String)
      : null,
  normalizedPosition: Offset(
    (json['x'] as num).toDouble(),
    (json['y'] as num).toDouble(),
  ),
  timestamp: DateTime.parse(json['timestamp'] as String),
)).toList();

BodyPartSelector(
  side: BodySide.front,
  bodyParts: bodyParts,
  onSelectionUpdated: onSelectionUpdated,
  initialMarkers: markers,
);

final turnableMarkers = {
  BodySide.front: markers,
  BodySide.back: backMarkers,
  BodySide.left: leftMarkers,
  BodySide.right: rightMarkers,
};

BodyPartSelectorTurnable(
  bodyParts: bodyParts,
  initialMarkers: turnableMarkers,
);
```

Each time the user taps, the callback returns the updated `markers` list, which
you can persist back into your storage layer.

### Constructor parameters

**BodyPartSelector**

- `bodyParts` (required): current selection object.
- `onSelectionUpdated` (required, nullable): invoked with the updated
  `BodyParts` after each interaction.
- `side` (required): which body side to render.
- `onBodyPartTapped` (optional): detailed tap callback with marker payload.
- `mirrored` (optional, defaults to `false`): toggle symmetrical selection.
- `selectedColor` (optional): highlight colour; defaults to
  `Theme.of(context).colorScheme.inversePrimary`.
- `unselectedColor` (optional): base fill colour; defaults to
  `Theme.of(context).colorScheme.inverseSurface`.
- `selectedOutlineColor` (optional): outline for active segments; defaults to
  `Theme.of(context).colorScheme.primary`.
- `unselectedOutlineColor` (optional): outline for inactive segments; defaults
  to `Theme.of(context).colorScheme.onInverseSurface`.
- `initialMarkers` (optional, defaults to empty list): pre-loaded markers for
  the current side.
- `markerColor` (optional): fill colour for pins; defaults to tertiary colour.
- `markerOutlineColor` (optional): outline colour for pins when
  `markerHasOutline` is `true`.
- `bodyFillColor` (optional): overrides base body fill colour.
- `bodyOutlineColor` (optional): overrides base outline colour.
- `bodyOutlineWidth` (optional, defaults to `2.0`): stroke width for outlines.
- `highlightColor` (optional): fill colour for selected segments.
- `markerRadius` (optional, defaults to `6.0`, minimum `1.0`): pin radius.
- `markerHasOutline` (optional, defaults to `true`): show or hide pin outlines.
- `activeMarkerColor` (optional): fill colour for the currently focused pin;
  defaults to `colorScheme.secondary`.

**BodyPartSelectorTurnable**

- `bodyParts` (required): current selection shared across rotations.
- `onSelectionUpdated` (optional): called when the shared selection changes.
- `onBodyPartTapped` (optional): detailed tap callback.
- `mirrored` (optional, defaults to `false`).
- `selectedColor`, `unselectedColor`, `selectedOutlineColor`,
  `unselectedOutlineColor` (optional): forwarded to the underlying selector.
- `padding` (optional, defaults to `EdgeInsets.zero`): outer padding around the
  rotation stage.
- `labelData` (optional, defaults to English labels): captions for the four
  sides.
- `initialMarkers` (optional, defaults to empty map): map of `BodySide` to
  marker lists.
- `markerColor`, `markerOutlineColor`, `bodyFillColor`, `bodyOutlineColor`,
  `bodyOutlineWidth`, `highlightColor`, `markerRadius`, `markerHasOutline`,
  `activeMarkerColor` (optional): forwarded to the inner `BodyPartSelector` for
  each side.
- `rotateRightTrigger` (optional, defaults to `0`): increment the value to
  rotate clockwise once (handy for FlutterFlow actions).
- `rotateButtonIcon` (optional): supply a custom icon widget for the built-in
  rotate button; defaults to an SVG glyph bundled with the package.
- `showRotateButton` (optional, defaults to `true`): hides the built-in rotate
  button when set to `false`.
- `onRotateRequested` (optional): callback invoked right before any clockwise
  rotation (built-in button or external trigger) is executed.

To rotate from FlutterFlow, bind a numeric state value to `rotateRightTrigger`
and increment it inside your button action; the widget detects the change and
animates one step clockwise.

When using `BodyPartSelectorTurnable`, supply `initialMarkers` as a map keyed by
`BodySide` to pre-populate markers for each side, and handle the same
`onBodyPartTapped` callback to keep the data in sync with your backend.

## Example
To run the example open the ``example`` folder and run ``flutter create .``


### Asset attribution

The illustrative body SVGs bundled with this package originate from
[Flow-Orbiter's human_body_selector_fo project][asset_credit] and are used in
accordance with its license. Please retain the original attribution if you
reuse or modify these assets.

[asset_credit]: https://github.com/Flow-Orbiter/human_body_selector_fo/tree/main/assets
---

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[mason_link]: https://github.com/felangel/mason
