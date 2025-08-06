import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as picker;
import '../models/file_upload_model.dart';

/// 파일 업로드 서비스 (목업 구현)
class FileUploadService {
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  final ImagePicker _imagePicker = ImagePicker();

  /// 이미지 파일 선택 (갤러리)
  Future<UploadResult> pickImageFromGallery({
    bool allowMultiple = false,
    int? imageQuality = 80,
  }) async {
    try {
      if (allowMultiple) {
        final List<XFile>? images = await _imagePicker.pickMultiImage(
          imageQuality: imageQuality,
        );
        
        if (images == null || images.isEmpty) {
          return UploadResult.cancelled();
        }

        List<UploadedFile> uploadedFiles = [];
        for (XFile image in images) {
          final validation = await _validateFile(image);
          if (!validation.isValid) {
            return UploadResult.error(validation.errorMessage!);
          }
          
          final uploadedFile = await _processImageFile(image);
          uploadedFiles.add(uploadedFile);
        }
        
        return UploadResult.success(uploadedFiles);
      } else {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: imageQuality,
        );
        
        if (image == null) {
          return UploadResult.cancelled();
        }

        final validation = await _validateFile(image);
        if (!validation.isValid) {
          return UploadResult.error(validation.errorMessage!);
        }
        
        final uploadedFile = await _processImageFile(image);
        return UploadResult.success([uploadedFile]);
      }
    } catch (e) {
      return UploadResult.error('이미지 선택 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 이미지 파일 선택 (카메라)
  Future<UploadResult> pickImageFromCamera({
    int? imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
      );
      
      if (image == null) {
        return UploadResult.cancelled();
      }

      final validation = await _validateFile(image);
      if (!validation.isValid) {
        return UploadResult.error(validation.errorMessage!);
      }
      
      final uploadedFile = await _processImageFile(image);
      return UploadResult.success([uploadedFile]);
    } catch (e) {
      return UploadResult.error('카메라 촬영 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 문서 파일 선택
  Future<UploadResult> pickDocument() async {
    try {
      picker.FilePickerResult? result = await picker.FilePicker.platform.pickFiles(
        type: picker.FileType.custom,
        allowedExtensions: allowedDocumentTypes,
      );

      if (result == null || result.files.isEmpty) {
        return UploadResult.cancelled();
      }

      final file = result.files.first;
      
      // 파일 크기 검증
      if (file.size > maxDocumentSize) {
        return UploadResult.error('파일 크기가 너무 큽니다. (최대 ${(maxDocumentSize / (1024 * 1024)).toInt()}MB)');
      }

      final uploadedFile = await _processDocumentFile(file);
      return UploadResult.success([uploadedFile]);
    } catch (e) {
      return UploadResult.error('문서 선택 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 파일 업로드 (목업 - 실제로는 서버에 업로드)
  Future<UploadResult> uploadFiles(List<UploadedFile> files) async {
    try {
      // 목업 구현: 실제로는 서버 API 호출
      await Future.delayed(const Duration(milliseconds: 1500)); // 업로드 시뮬레이션
      
      // 목업 URL 생성
      List<UploadedFile> uploadedFiles = files.map((file) {
        return file.copyWith(
          serverUrl: _generateMockUrl(file.fileName),
          status: FileUploadStatus.uploaded,
          uploadedAt: DateTime.now(),
        );
      }).toList();
      
      return UploadResult.success(uploadedFiles);
    } catch (e) {
      return UploadResult.error('파일 업로드에 실패했습니다: ${e.toString()}');
    }
  }

  /// 파일 삭제 (목업)
  Future<bool> deleteFile(String fileUrl) async {
    try {
      // 목업 구현: 실제로는 서버 API 호출
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      debugPrint('파일 삭제 실패: ${e.toString()}');
      return false;
    }
  }

  /// 파일 유효성 검사
  Future<FileValidationResult> _validateFile(XFile file) async {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      
      // 파일 크기 확인
      final int fileSize = await file.length();
      if (fileSize > maxImageSize) {
        return FileValidationResult(
          isValid: false,
          errorMessage: '파일 크기가 너무 큽니다. (최대 ${(maxImageSize / (1024 * 1024)).toInt()}MB)',
        );
      }
      
      // 파일 확장자 확인
      if (!allowedImageTypes.contains(extension)) {
        return FileValidationResult(
          isValid: false,
          errorMessage: '지원하지 않는 파일 형식입니다. (${allowedImageTypes.join(', ')}만 가능)',
        );
      }
      
      return FileValidationResult(isValid: true);
    } catch (e) {
      return FileValidationResult(
        isValid: false,
        errorMessage: '파일 검증 중 오류가 발생했습니다.',
      );
    }
  }

  /// 이미지 파일 처리
  Future<UploadedFile> _processImageFile(XFile file) async {
    final bytes = await file.readAsBytes();
    final fileSize = bytes.length;
    
    return UploadedFile(
      id: _generateFileId(),
      fileName: file.name,
      filePath: file.path,
      fileSize: fileSize,
      mimeType: _getMimeType(file.name),
      fileType: FileType.image,
      thumbnailPath: file.path, // 썸네일은 원본과 동일하게 처리 (목업)
      status: FileUploadStatus.selected,
      createdAt: DateTime.now(),
    );
  }

  /// 문서 파일 처리
  Future<UploadedFile> _processDocumentFile(picker.PlatformFile file) async {
    return UploadedFile(
      id: _generateFileId(),
      fileName: file.name,
      filePath: file.path ?? '',
      fileSize: file.size,
      mimeType: _getMimeType(file.name),
      fileType: FileType.document,
      status: FileUploadStatus.selected,
      createdAt: DateTime.now(),
    );
  }

  /// MIME 타입 추정
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  /// 목업 URL 생성
  String _generateMockUrl(String fileName) {
    const baseUrl = 'https://api.sellerseller.co.kr/uploads';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$baseUrl/$timestamp-$fileName';
  }

  /// 고유 파일 ID 생성
  String _generateFileId() {
    return 'file_${DateTime.now().millisecondsSinceEpoch}_${(1000 + DateTime.now().microsecond % 9000)}';
  }
}

/// 파일 유효성 검사 결과
class FileValidationResult {
  final bool isValid;
  final String? errorMessage;

  FileValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}
