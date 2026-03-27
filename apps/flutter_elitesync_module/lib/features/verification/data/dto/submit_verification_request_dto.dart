class SubmitVerificationRequestDto {
  const SubmitVerificationRequestDto({
    required this.realName,
    required this.idNumber,
  });

  final String realName;
  final String idNumber;

  Map<String, dynamic> toJson() {
    return {'real_name': realName, 'id_number': idNumber};
  }
}
