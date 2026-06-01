import 'dart:convert';

class CertificationModel {
  final String title;
  final String issueDate;
  final String fileUrl;
  final String fileType;
  final String uploadedAt;

  CertificationModel({
    required this.title,
    required this.issueDate,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'issueDate': issueDate,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'uploadedAt': uploadedAt,
    };
  }

  factory CertificationModel.fromMap(Map<String, dynamic> map) {
    return CertificationModel(
      title: map['title'] ?? '',
      issueDate: map['issueDate'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileType: map['fileType'] ?? '',
      uploadedAt: map['uploadedAt'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CertificationModel.fromJson(String source) =>
      CertificationModel.fromMap(json.decode(source));

  /// Safely parses a string that might either be a legacy plain text string
  /// or a new JSON-encoded CertificationModel string.
  static CertificationModel parseString(String data) {
    try {
      final decoded = json.decode(data);
      if (decoded is Map<String, dynamic>) {
        return CertificationModel.fromMap(decoded);
      }
    } catch (_) {
      // It's a legacy string, create a fallback model
    }
    
    return CertificationModel(
      title: data,
      issueDate: 'Unknown',
      fileUrl: '',
      fileType: 'unknown',
      uploadedAt: DateTime.now().toIso8601String(),
    );
  }
}
