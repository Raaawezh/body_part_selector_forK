import 'body_part_id.dart';
import 'body_parts.dart';

/// Convenience methods for enum-based toggling.
extension BodyPartsToggleX on BodyParts {
  /// Toggle a single enum id.
  BodyParts toggle(BodyPartId id, {bool mirror = false}) =>
      withToggledId(id.name, mirror: mirror);

  /// Toggle many ids in sequence. Returns the final updated instance.
  BodyParts toggleMany(Iterable<BodyPartId> ids, {bool mirror = false}) {
    var current = this;
    for (final id in ids) {
      current = current.toggle(id, mirror: mirror);
    }
    return current;
  }
}
