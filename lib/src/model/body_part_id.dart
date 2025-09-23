/// Enum listing all selectable body part identifiers.
///
/// Nazwy muszą być 1:1 zgodne z kluczami pól w `BodyParts` oraz z atrybutami
/// `id` w plikach SVG aby mechanizmy togglowania i mapowania działały.
enum BodyPartId {
  head,
  neck,
  leftShoulder,
  leftUpperArm,
  leftElbow,
  leftLowerArm,
  leftHand,
  rightShoulder,
  rightUpperArm,
  rightElbow,
  rightLowerArm,
  rightHand,
  upperBody,
  lowerBody,
  leftUpperLeg,
  leftKnee,
  leftLowerLeg,
  leftFoot,
  rightUpperLeg,
  rightKnee,
  rightLowerLeg,
  rightFoot,
  abdomen,
  vestibular,
}

extension BodyPartIdX on BodyPartId {
  /// String identifier used in JSON/SVG.
  String get id => name;
}
