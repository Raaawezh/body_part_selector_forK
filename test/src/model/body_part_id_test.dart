import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BodyPartId enum', () {
    test('enum values cover all BodyParts keys', () {
      final keys = const BodyParts().toMap().keys.toSet();
      final enumNames = BodyPartId.values.map((e) => e.name).toSet();
      expect(enumNames, keys);
    });

    test('fromIds + selectedIds roundtrip', () {
      final original = BodyParts.fromIds(BodyPartId.values);
      final roundtrip = BodyParts.fromIds(original.selectedIds);
      expect(roundtrip, original);
    });

    test('partial selection roundtrip', () {
      final subset = [
        BodyPartId.head,
        BodyPartId.leftKnee,
        BodyPartId.rightElbow,
        BodyPartId.abdomen,
      ];
      final bp = BodyParts.fromIds(subset);
      expect(bp.selectedIds.toSet(), subset.toSet());
    });
  });
}
