class MedicalRecord {
  final String id;
  final String patientName;
  final String email;
  final String phone;
  final String socialSecurityNumber;
  final String medicalHistory;
  final DateTime createdAt;
  final String doctorId;

  MedicalRecord({
    required this.id,
    required this.patientName,
    required this.email,
    required this.phone,
    required this.socialSecurityNumber,
    required this.medicalHistory,
    required this.createdAt,
    required this.doctorId,
  });

  factory MedicalRecord.fromMap(Map<String, dynamic> data, String id) {
    return MedicalRecord(
      id: id,
      patientName: data['patientName'] ?? 'Patient',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      socialSecurityNumber: data['socialSecurityNumber'] ?? '',
      medicalHistory: data['medicalHistory'] ?? '',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      doctorId: data['doctorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'email': email,
      'phone': phone,
      'socialSecurityNumber': socialSecurityNumber,
      'medicalHistory': medicalHistory,
      'createdAt': createdAt,
      'doctorId': doctorId,
    };
  }
}
