enum CampaignStatus { recruiting, active, completed, cancelled }

class Campaign {
  final String id;
  final String sellerId;
  final String name;
  final List<String> categories;
  final int budget;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String targetConditions;
  final List<String> attachedFiles;
  final CampaignStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // 지원자 관련
  final List<String> applicantIds;
  final int maxApplicants;
  
  Campaign({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.categories,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.targetConditions,
    this.attachedFiles = const [],
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.applicantIds = const [],
    this.maxApplicants = 10,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      sellerId: json['seller_id'],
      name: json['name'],
      categories: List<String>.from(json['categories'] ?? []),
      budget: json['budget'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      description: json['description'],
      targetConditions: json['target_conditions'],
      attachedFiles: List<String>.from(json['attached_files'] ?? []),
      status: CampaignStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      applicantIds: List<String>.from(json['applicant_ids'] ?? []),
      maxApplicants: json['max_applicants'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'name': name,
      'categories': categories,
      'budget': budget,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'description': description,
      'target_conditions': targetConditions,
      'attached_files': attachedFiles,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'applicant_ids': applicantIds,
      'max_applicants': maxApplicants,
    };
  }

  Campaign copyWith({
    String? id,
    String? sellerId,
    String? name,
    List<String>? categories,
    int? budget,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? targetConditions,
    List<String>? attachedFiles,
    CampaignStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? applicantIds,
    int? maxApplicants,
  }) {
    return Campaign(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      categories: categories ?? this.categories,
      budget: budget ?? this.budget,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      targetConditions: targetConditions ?? this.targetConditions,
      attachedFiles: attachedFiles ?? this.attachedFiles,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      applicantIds: applicantIds ?? this.applicantIds,
      maxApplicants: maxApplicants ?? this.maxApplicants,
    );
  }
}
