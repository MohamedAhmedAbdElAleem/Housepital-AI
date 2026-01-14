// Cloudinary Service - Flutter Client
//
// This service handles all image operations with the backend:
// - Upload images (camera, gallery, base64)
// - Delete images
// - Get transformed URLs
//
// Usage:
// ```dart
// final cloudinaryService = CloudinaryService();
// final result = await cloudinaryService.uploadBase64(base64Image, folder: CloudinaryFolder.idDocuments);
// ```

import 'dart:convert';
import 'dart:io';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_constants.dart';

/// Folder types for organizing uploads
enum CloudinaryFolder {
  profiles,
  idDocuments,
  medicalRecords,
  prescriptions,
  general,
}

/// Extension to convert folder enum to string
extension CloudinaryFolderExtension on CloudinaryFolder {
  String get value {
    switch (this) {
      case CloudinaryFolder.profiles:
        return 'profiles';
      case CloudinaryFolder.idDocuments:
        return 'id_documents';
      case CloudinaryFolder.medicalRecords:
        return 'medical_records';
      case CloudinaryFolder.prescriptions:
        return 'prescriptions';
      case CloudinaryFolder.general:
        return 'general';
    }
  }
}

/// Response model for upload operations
class CloudinaryUploadResponse {
  final bool success;
  final String? url;
  final String? publicId;
  final String? format;
  final int? width;
  final int? height;
  final int? size;
  final String? error;

  CloudinaryUploadResponse({
    required this.success,
    this.url,
    this.publicId,
    this.format,
    this.width,
    this.height,
    this.size,
    this.error,
  });

  factory CloudinaryUploadResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CloudinaryUploadResponse(
      success: json['success'] ?? false,
      url: data?['url'],
      publicId: data?['publicId'],
      format: data?['format'],
      width: data?['width'],
      height: data?['height'],
      size: data?['size'],
      error: json['message'],
    );
  }

  factory CloudinaryUploadResponse.error(String message) {
    return CloudinaryUploadResponse(success: false, error: message);
  }
}

/// Response model for delete operations
class CloudinaryDeleteResponse {
  final bool success;
  final String? message;

  CloudinaryDeleteResponse({required this.success, this.message});

  factory CloudinaryDeleteResponse.fromJson(Map<String, dynamic> json) {
    return CloudinaryDeleteResponse(
      success: json['success'] ?? false,
      message: json['message'],
    );
  }
}

/// Cloudinary Service for handling image uploads
class CloudinaryService {
  final ApiService _apiService;

  CloudinaryService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  /// Upload base64 encoded image
  ///
  /// [base64Image] - The base64 string (with or without data URI prefix)
  /// [folder] - Target folder in Cloudinary
  /// [publicId] - Optional custom public ID
  Future<CloudinaryUploadResponse> uploadBase64(
    String base64Image, {
    CloudinaryFolder folder = CloudinaryFolder.general,
    String? publicId,
  }) async {
    try {
      final body = <String, dynamic>{
        'image': base64Image,
        'folder': folder.value,
      };
      if (publicId != null) body['publicId'] = publicId;

      final response = await _apiService.post(
        ApiConstants.cloudinaryUploadBase64,
        body: body,
      );

      return CloudinaryUploadResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      return CloudinaryUploadResponse.error(e.toString());
    }
  }

  /// Upload image file (from camera or gallery) - Multipart upload (Recommended)
  ///
  /// [file] - The image file
  /// [folder] - Target folder in Cloudinary
  Future<CloudinaryUploadResponse> uploadFile(
    File file, {
    CloudinaryFolder folder = CloudinaryFolder.general,
  }) async {
    try {
      final response = await _apiService.uploadFile(
        ApiConstants.cloudinaryUpload,
        file,
        fieldName: 'file',
        extraFields: {'folder': folder.value},
      );

      return CloudinaryUploadResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      return CloudinaryUploadResponse.error(e.toString());
    }
  }

  /// Upload image from URL
  ///
  /// [imageUrl] - The source image URL
  /// [folder] - Target folder in Cloudinary
  Future<CloudinaryUploadResponse> uploadFromUrl(
    String imageUrl, {
    CloudinaryFolder folder = CloudinaryFolder.general,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.cloudinaryBase}/upload-url',
        body: {'url': imageUrl, 'folder': folder.value},
      );

      return CloudinaryUploadResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      return CloudinaryUploadResponse.error(e.toString());
    }
  }

  /// Delete single image using POST (since our ApiService.delete doesn't support body)
  ///
  /// [publicId] - The Cloudinary public ID of the image
  Future<CloudinaryDeleteResponse> deleteImage(String publicId) async {
    try {
      // Using POST with action=delete since standard DELETE doesn't support body
      final response = await _apiService.post(
        ApiConstants.cloudinaryDelete,
        body: {'publicId': publicId},
      );

      return CloudinaryDeleteResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      return CloudinaryDeleteResponse(success: false, message: e.toString());
    }
  }

  /// Delete multiple images
  ///
  /// [publicIds] - List of Cloudinary public IDs
  Future<CloudinaryDeleteResponse> deleteMultipleImages(
    List<String> publicIds,
  ) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.cloudinaryBase}/delete-multiple',
        body: {'publicIds': publicIds},
      );

      return CloudinaryDeleteResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      return CloudinaryDeleteResponse(success: false, message: e.toString());
    }
  }

  /// Replace existing image with new one
  ///
  /// [publicId] - The public ID of image to replace
  /// [newBase64Image] - The new image in base64
  Future<CloudinaryUploadResponse> replaceImage(
    String publicId,
    String newBase64Image,
  ) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.cloudinaryBase}/replace',
        body: {'publicId': publicId, 'image': newBase64Image},
      );

      return CloudinaryUploadResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      return CloudinaryUploadResponse.error(e.toString());
    }
  }

  /// Get transformed URL for an image
  ///
  /// [publicId] - The Cloudinary public ID
  /// [width] - Target width
  /// [height] - Target height
  Future<String?> getTransformedUrl(
    String publicId, {
    int? width,
    int? height,
    String crop = 'fill',
    String quality = 'auto',
  }) async {
    try {
      String url =
          '${ApiConstants.cloudinaryBase}/transform?publicId=$publicId';
      if (width != null) url += '&width=$width';
      if (height != null) url += '&height=$height';
      url += '&crop=$crop&quality=$quality';

      final response = await _apiService.get(url);
      final data = response as Map<String, dynamic>;

      if (data['success'] == true) {
        return data['url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get thumbnail URL
  ///
  /// [publicId] - The Cloudinary public ID
  /// [size] - Thumbnail size (default: 150)
  Future<String?> getThumbnailUrl(String publicId, {int size = 150}) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.cloudinaryBase}/thumbnail?publicId=$publicId&size=$size',
      );
      final data = response as Map<String, dynamic>;

      if (data['success'] == true) {
        return data['url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check Cloudinary service status
  Future<bool> checkStatus() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.cloudinaryBase}/status',
      );
      final data = response as Map<String, dynamic>;

      return data['configured'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Helper: Convert File to base64
  static Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Helper: Get file extension from path
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Helper: Check if file is valid image
  static bool isValidImage(String path) {
    final validExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'heic',
      'heif',
    ];
    final extension = getFileExtension(path);
    return validExtensions.contains(extension);
  }

  /// Helper: Check if file is PDF
  static bool isPdf(String path) {
    return getFileExtension(path) == 'pdf';
  }
}
