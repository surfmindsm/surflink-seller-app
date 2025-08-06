import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/file_upload_model.dart';
import '../../services/file_upload_service.dart';
import '../../utils/theme.dart';

/// 파일 업로드 위젯
class FileUploadWidget extends StatefulWidget {
  final List<UploadedFile>? initialFiles;
  final FilePickerOptions options;
  final Function(List<UploadedFile>) onFilesChanged;
  final String title;
  final String? description;
  final bool enabled;
  final int? maxFiles;

  const FileUploadWidget({
    Key? key,
    this.initialFiles,
    required this.options,
    required this.onFilesChanged,
    this.title = '파일 선택',
    this.description,
    this.enabled = true,
    this.maxFiles,
  }) : super(key: key);

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final FileUploadService _fileUploadService = FileUploadService();
  List<UploadedFile> _files = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _files = widget.initialFiles ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.grey600,
                        ),
                      ),
                    ],
                  ],
                ),
                if (_files.isNotEmpty)
                  Text(
                    '${_files.length}${widget.maxFiles != null ? '/${widget.maxFiles}' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.grey600,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 파일 선택 버튼
            if (widget.enabled && (widget.maxFiles == null || _files.length < widget.maxFiles!))
              _buildUploadButton(),

            const SizedBox(height: 16),

            // 파일 목록
            if (_files.isNotEmpty) _buildFileList(),

            // 업로드 진행 상태
            if (_isUploading)
              const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  /// 업로드 버튼 빌드
  Widget _buildUploadButton() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.grey300,
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.grey50,
      ),
      child: InkWell(
        onTap: _showFilePickerOptions,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.options.fileType == FileType.image
                  ? Icons.add_photo_alternate
                  : Icons.attach_file,
              size: 32,
              color: AppTheme.grey500,
            ),
            const SizedBox(height: 8),
            Text(
              widget.options.fileType == FileType.image
                  ? '이미지 추가'
                  : '파일 추가',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.grey700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getFileTypeDescription(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 파일 목록 빌드
  Widget _buildFileList() {
    return Column(
      children: _files.map((file) => _buildFileItem(file)).toList(),
    );
  }

  /// 파일 아이템 빌드
  Widget _buildFileItem(UploadedFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grey200),
        borderRadius: BorderRadius.circular(8),
        color: file.isFailed ? Colors.red.shade50 : null,
      ),
      child: Row(
        children: [
          // 파일 아이콘/썸네일
          _buildFileIcon(file),
          
          const SizedBox(width: 12),
          
          // 파일 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      file.formattedFileSize,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(file),
                  ],
                ),
                if (file.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    file.errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (file.isUploading && file.progress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(
                      value: file.progress,
                      backgroundColor: AppTheme.grey200,
                    ),
                  ),
              ],
            ),
          ),
          
          // 삭제 버튼
          if (widget.enabled)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => _removeFile(file),
              color: AppTheme.grey500,
            ),
        ],
      ),
    );
  }

  /// 파일 아이콘 빌드
  Widget _buildFileIcon(UploadedFile file) {
    if (file.isImage && file.filePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(file.filePath),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultFileIcon(file);
          },
        ),
      );
    } else {
      return _buildDefaultFileIcon(file);
    }
  }

  /// 기본 파일 아이콘
  Widget _buildDefaultFileIcon(UploadedFile file) {
    IconData icon;
    Color color;

    switch (file.fileType) {
      case FileType.image:
        icon = Icons.image;
        color = Colors.blue;
        break;
      case FileType.document:
        icon = Icons.description;
        color = Colors.orange;
        break;
      case FileType.video:
        icon = Icons.videocam;
        color = Colors.purple;
        break;
      case FileType.audio:
        icon = Icons.audiotrack;
        color = Colors.green;
        break;
      default:
        icon = Icons.attach_file;
        color = AppTheme.grey500;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  /// 상태 배지 빌드
  Widget _buildStatusBadge(UploadedFile file) {
    String text;
    Color color;

    switch (file.status) {
      case FileUploadStatus.selected:
        text = '선택됨';
        color = AppTheme.grey500;
        break;
      case FileUploadStatus.uploading:
        text = '업로드 중';
        color = Colors.blue;
        break;
      case FileUploadStatus.uploaded:
        text = '완료';
        color = Colors.green;
        break;
      case FileUploadStatus.failed:
        text = '실패';
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 파일 선택 옵션 표시
  void _showFilePickerOptions() {
    if (widget.options.fileType == FileType.image) {
      _showImagePickerOptions();
    } else {
      _pickDocument();
    }
  }

  /// 이미지 선택 옵션 표시
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('갤러리에서 선택'),
            onTap: () {
              Navigator.pop(context);
              _pickImageFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('카메라로 촬영'),
            onTap: () {
              Navigator.pop(context);
              _pickImageFromCamera();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 갤러리에서 이미지 선택
  Future<void> _pickImageFromGallery() async {
    try {
      setState(() => _isUploading = true);
      
      final result = await _fileUploadService.pickImageFromGallery(
        allowMultiple: widget.options.allowMultiple,
        imageQuality: widget.options.imageQuality,
      );
      
      await _handleUploadResult(result);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// 카메라로 이미지 촬영
  Future<void> _pickImageFromCamera() async {
    try {
      setState(() => _isUploading = true);
      
      final result = await _fileUploadService.pickImageFromCamera(
        imageQuality: widget.options.imageQuality,
      );
      
      await _handleUploadResult(result);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// 문서 파일 선택
  Future<void> _pickDocument() async {
    try {
      setState(() => _isUploading = true);
      
      final result = await _fileUploadService.pickDocument();
      await _handleUploadResult(result);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  /// 업로드 결과 처리
  Future<void> _handleUploadResult(UploadResult result) async {
    if (result.isCancelled) return;
    
    if (!result.isSuccess) {
      _showErrorMessage(result.errorMessage ?? '파일 선택에 실패했습니다.');
      return;
    }
    
    if (result.files != null) {
      setState(() {
        _files.addAll(result.files!);
      });
      widget.onFilesChanged(_files);
      
      // 실제 업로드 시작
      _uploadFiles(result.files!);
    }
  }

  /// 파일 실제 업로드
  Future<void> _uploadFiles(List<UploadedFile> filesToUpload) async {
    try {
      final uploadResult = await _fileUploadService.uploadFiles(filesToUpload);
      
      if (uploadResult.isSuccess && uploadResult.files != null) {
        setState(() {
          for (var uploadedFile in uploadResult.files!) {
            final index = _files.indexWhere((f) => f.id == uploadedFile.id);
            if (index != -1) {
              _files[index] = uploadedFile;
            }
          }
        });
        widget.onFilesChanged(_files);
      }
    } catch (e) {
      _showErrorMessage('파일 업로드에 실패했습니다: ${e.toString()}');
    }
  }

  /// 파일 제거
  void _removeFile(UploadedFile file) {
    setState(() {
      _files.removeWhere((f) => f.id == file.id);
    });
    widget.onFilesChanged(_files);
    
    // 서버에서 파일 삭제 (업로드된 경우)
    if (file.isUploaded && file.serverUrl != null) {
      _fileUploadService.deleteFile(file.serverUrl!);
    }
  }

  /// 에러 메시지 표시
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// 파일 타입 설명 반환
  String _getFileTypeDescription() {
    switch (widget.options.fileType) {
      case FileType.image:
        return 'JPG, PNG, GIF 파일 (최대 5MB)';
      case FileType.document:
        return 'PDF, DOC, DOCX 파일 (최대 10MB)';
      default:
        return '파일을 선택하세요';
    }
  }
}
