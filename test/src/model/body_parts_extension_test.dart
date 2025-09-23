import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BodyPartsToggleX extension', () {
    test('toggle single id', () {
      const empty = BodyParts();
      final updated = empty.toggle(BodyPartId.leftKnee);
      expect(updated.toMap()['leftKnee'], isTrue);
      expect(updated.selectedIds.contains(BodyPartId.leftKnee), isTrue);
    });

    test('toggleMany sequence', () {
      const empty = BodyParts();
      final updated = empty.toggleMany([
        BodyPartId.head,
        BodyPartId.rightElbow,
        BodyPartId.rightElbow, // toggled twice -> off
        BodyPartId.abdomen,
      ]);
      expect(updated.toMap()['head'], isTrue);
      expect(updated.toMap()['rightElbow'], isFalse);
      expect(updated.toMap()['abdomen'], isTrue);
    });

    test('mirror works through sugar', () {
      const empty = BodyParts();
      final updated = empty.toggle(BodyPartId.leftShoulder, mirror: true);
      expect(updated.toMap()['leftShoulder'], isTrue);
      expect(updated.toMap()['rightShoulder'], isTrue);
    });
  });
}
