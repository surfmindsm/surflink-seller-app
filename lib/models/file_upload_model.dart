import 'package:flutter/foundation.dart';

/// 파일 업로드 상태
enum FileUploadStatus {
  selected,   // 선택됨
  uploading,  // 업로드 중
  uploaded,   // 업로드 완료
  failed,     // 업로드 실패
}

/// 파일 타입
enum FileType {
  image,      // 이미지 파일
  document,   // 문서 파일
  video,      // 비디오 파일
  audio,      // 오디오 파일
  other,      // 기타
}

/// 업로드된 파일 정보
class UploadedFile {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String mimeType;
  final FileType fileType;
  final String? thumbnailPath;
  final String? serverUrl;
  final FileUploadStatus status;
  final DateTime createdAt;
  final DateTime? uploadedAt;
  final double? progress;
  final String? errorMessage;

  UploadedFile({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    required this.fileType,
    this.thumbnailPath,
    this.serverUrl,
    required this.status,
    required this.createdAt,
    this.uploadedAt,
    this.progress,
    this.errorMessage,
  });

  /// 파일 크기를 사람이 읽기 쉬운 형태로 변환
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  /// 파일 확장자
  String get extension {
    return fileName.split('.').last.toLowerCase();
  }

  /// 이미지 파일 여부
  bool get isImage {
    return fileType == FileType.image;
  }

  /// 문서 파일 여부
  bool get isDocument {
    return fileType == FileType.document;
  }

  /// 업로드 완료 여부
  bool get isUploaded {
    return status == FileUploadStatus.uploaded;
  }

  /// 업로드 중 여부
  bool get isUploading {
    return status == FileUploadStatus.uploading;
  }

  /// 업로드 실패 여부
  bool get isFailed {
    return status == FileUploadStatus.failed;
  }

  /// 복사본 생성
  UploadedFile copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? fileSize,
    String? mimeType,
    FileType? fileType,
    String? thumbnailPath,
    String? serverUrl,
    FileUploadStatus? status,
    DateTime? createdAt,
    DateTime? uploadedAt,
    double? progress,
    String? errorMessage,
  }) {
    return UploadedFile(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      fileType: fileType ?? this.fileType,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      serverUrl: serverUrl ?? this.serverUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'file_size': fileSize,
      'mime_type': mimeType,
      'file_type': fileType.name,
      'thumbnail_path': thumbnailPath,
      'server_url': serverUrl,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'uploaded_at': uploadedAt?.toIso8601String(),
      'progress': progress,
      'error_message': errorMessage,
    };
  }

  /// JSON 역직렬화
  factory UploadedFile.fromJson(Map<String, dynamic> json) {
    return UploadedFile(
      id: json['id'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      fileSize: json['file_size'],
      mimeType: json['mime_type'],
      fileType: FileType.values.firstWhere(
        (e) => e.name == json['file_type'],
        orElse: () => FileType.other,
      ),
      thumbnailPath: json['thumbnail_path'],
      serverUrl: json['server_url'],
      status: FileUploadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FileUploadStatus.selected,
      ),
      createdAt: DateTime.parse(json['created_at']),
      uploadedAt: json['uploaded_at'] != null ? DateTime.parse(json['uploaded_at']) : null,
      progress: json['progress']?.toDouble(),
      errorMessage: json['error_message'],
    );
  }
}

/// 파일 업로드 결과
class UploadResult {
  final bool isSuccess;
  final List<UploadedFile>? files;
  final String? errorMessage;
  final bool isCancelled;

  UploadResult._({
    required this.isSuccess,
    this.files,
    this.errorMessage,
    this.isCancelled = false,
  });

  /// 성공 결과
  factory UploadResult.success(List<UploadedFile> files) {
    return UploadResult._(
      isSuccess: true,
      files: files,
    );
  }

  /// 에러 결과
  factory UploadResult.error(String message) {
    return UploadResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }

  /// 취소 결과
  factory UploadResult.cancelled() {
    return UploadResult._(
      isSuccess: false,
      isCancelled: true,
    );
  }

  /// 첫 번째 파일
  UploadedFile? get firstFile {
    return files?.isNotEmpty == true ? files!.first : null;
  }
}

/// 파일 업로드 진행 상태
class UploadProgress {
  final String fileId;
  final double progress; // 0.0 ~ 1.0
  final int uploadedBytes;
  final int totalBytes;
  final FileUploadStatus status;
  final String? errorMessage;

  UploadProgress({
    required this.fileId,
    required this.progress,
    required this.uploadedBytes,
    required this.totalBytes,
    required this.status,
    this.errorMessage,
  });

  /// 진행률 (퍼센트)
  int get progressPercent {
    return (progress * 100).round();
  }

  /// 남은 용량
  int get remainingBytes {
    return totalBytes - uploadedBytes;
  }
}

/// 파일 선택 옵션
class FilePickerOptions {
  final bool allowMultiple;
  final FileType fileType;
  final List<String>? allowedExtensions;
  final int? maxFileSize;
  final int? imageQuality;
  final bool compressionEnabled;

  const FilePickerOptions({
    this.allowMultiple = false,
    this.fileType = FileType.image,
    this.allowedExtensions,
    this.maxFileSize,
    this.imageQuality = 80,
    this.compressionEnabled = true,
  });
}

/// 이미지 압축 옵션
class ImageCompressionOptions {
  final int? quality;
  final int? maxWidth;
  final int? maxHeight;
  final bool maintainAspectRatio;

  const ImageCompressionOptions({
    this.quality = 80,
    this.maxWidth,
    this.maxHeight,
    this.maintainAspectRatio = true,
  });
}
