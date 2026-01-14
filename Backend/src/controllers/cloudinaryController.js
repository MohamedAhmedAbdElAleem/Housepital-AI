/**
 * Cloudinary Controller - API Endpoints for Image Management
 * 
 * Endpoints:
 * POST   /api/cloudinary/upload          - Upload file (multipart)
 * POST   /api/cloudinary/upload-base64   - Upload base64 image
 * POST   /api/cloudinary/upload-url      - Upload from URL
 * DELETE /api/cloudinary/delete          - Delete single image
 * DELETE /api/cloudinary/delete-multiple - Delete multiple images
 * GET    /api/cloudinary/transform       - Get transformed URL
 * GET    /api/cloudinary/status          - Check Cloudinary status
 */

const multer = require('multer');
const cloudinaryService = require('../services/cloudinaryService');

// Multer configuration for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
  },
  fileFilter: (req, file, cb) => {
    console.log('📁 Received file:', {
      originalname: file.originalname,
      mimetype: file.mimetype,
      encoding: file.encoding,
    });

    // Allow images and PDFs based on mimetype OR file extension
    const allowedMimes = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/gif',
      'image/webp',
      'image/heic',
      'image/heif',
      'application/pdf',
      'application/octet-stream', // Generic binary - check extension
    ];

    // Check file extension as fallback
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic', '.heif', '.pdf'];
    const ext = file.originalname.toLowerCase().substring(file.originalname.lastIndexOf('.'));
    const isAllowedExtension = allowedExtensions.includes(ext);

    if (allowedMimes.includes(file.mimetype) || isAllowedExtension) {
      console.log('✅ File accepted');
      cb(null, true);
    } else {
      console.log('❌ File rejected - mimetype:', file.mimetype, 'ext:', ext);
      cb(new Error(`Invalid file type: ${file.mimetype}. Only images and PDFs are allowed.`), false);
    }
  },
});

/**
 * Upload file from multipart form data
 * @route POST /api/cloudinary/upload
 * @body file - The file to upload (multipart)
 * @body folder - Target folder (optional, default: 'general')
 */
const uploadFile = async (req, res) => {
  try {
    console.log('📤 Upload request received');
    console.log('📁 File:', req.file ? { 
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size 
    } : 'No file');
    console.log('📂 Body folder:', req.body.folder);

    if (!req.file) {
      console.log('❌ No file in request');
      return res.status(400).json({
        success: false,
        message: 'No file provided',
      });
    }

    const folder = req.body.folder || 'general';
    const folderPath = cloudinaryService.FOLDERS[folder.toUpperCase()] || cloudinaryService.FOLDERS.GENERAL;
    console.log('📂 Using folder path:', folderPath);

    console.log('☁️ Uploading to Cloudinary...');
    const result = await cloudinaryService.uploadFromBuffer(req.file.buffer, {
      folder: folderPath,
      resourceType: 'auto',
    });

    console.log('☁️ Cloudinary result:', result);

    if (result.success) {
      console.log('✅ Upload successful:', result.url);
      res.json({
        success: true,
        message: 'File uploaded successfully',
        data: {
          url: result.url,
          publicId: result.publicId,
          format: result.format,
          width: result.width,
          height: result.height,
          size: result.bytes,
        },
      });
    } else {
      console.log('❌ Upload failed:', result.error);
      res.status(500).json({
        success: false,
        message: result.error || 'Upload failed',
      });
    }
  } catch (error) {
    console.error('❌ Upload error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Upload base64 encoded image
 * @route POST /api/cloudinary/upload-base64
 * @body image - Base64 encoded image string
 * @body folder - Target folder (optional)
 * @body publicId - Custom public ID (optional)
 */
const uploadBase64 = async (req, res) => {
  try {
    const { image, folder = 'general', publicId = null } = req.body;

    if (!image) {
      return res.status(400).json({
        success: false,
        message: 'No image provided',
      });
    }

    const folderPath = cloudinaryService.FOLDERS[folder.toUpperCase()] || cloudinaryService.FOLDERS.GENERAL;

    const result = await cloudinaryService.uploadFromBase64(image, {
      folder: folderPath,
      publicId,
    });

    if (result.success) {
      res.json({
        success: true,
        message: 'Image uploaded successfully',
        data: {
          url: result.url,
          publicId: result.publicId,
          format: result.format,
          width: result.width,
          height: result.height,
          size: result.bytes,
        },
      });
    } else {
      res.status(500).json({
        success: false,
        message: result.error || 'Upload failed',
      });
    }
  } catch (error) {
    console.error('Base64 upload error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Upload image from URL
 * @route POST /api/cloudinary/upload-url
 * @body url - The image URL
 * @body folder - Target folder (optional)
 */
const uploadFromUrl = async (req, res) => {
  try {
    const { url, folder = 'general' } = req.body;

    if (!url) {
      return res.status(400).json({
        success: false,
        message: 'No URL provided',
      });
    }

    const folderPath = cloudinaryService.FOLDERS[folder.toUpperCase()] || cloudinaryService.FOLDERS.GENERAL;

    const result = await cloudinaryService.uploadFromUrl(url, {
      folder: folderPath,
    });

    if (result.success) {
      res.json({
        success: true,
        message: 'Image uploaded successfully',
        data: {
          url: result.url,
          publicId: result.publicId,
          format: result.format,
        },
      });
    } else {
      res.status(500).json({
        success: false,
        message: result.error || 'Upload failed',
      });
    }
  } catch (error) {
    console.error('URL upload error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Delete single image
 * @route DELETE /api/cloudinary/delete
 * @body publicId - The public ID of the image to delete
 */
const deleteImage = async (req, res) => {
  try {
    const { publicId } = req.body;

    if (!publicId) {
      return res.status(400).json({
        success: false,
        message: 'No publicId provided',
      });
    }

    const result = await cloudinaryService.deleteImage(publicId);

    res.json({
      success: result.success,
      message: result.success ? 'Image deleted successfully' : 'Failed to delete image',
      result: result.result,
    });
  } catch (error) {
    console.error('Delete error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Delete multiple images
 * @route DELETE /api/cloudinary/delete-multiple
 * @body publicIds - Array of public IDs to delete
 */
const deleteMultipleImages = async (req, res) => {
  try {
    const { publicIds } = req.body;

    if (!publicIds || !Array.isArray(publicIds) || publicIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No publicIds provided or invalid format',
      });
    }

    const result = await cloudinaryService.deleteMultipleImages(publicIds);

    res.json({
      success: result.success,
      message: result.success ? 'Images deleted successfully' : 'Failed to delete images',
      deleted: result.deleted,
      notFound: result.notFound,
    });
  } catch (error) {
    console.error('Bulk delete error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Get transformed image URL
 * @route GET /api/cloudinary/transform
 * @query publicId - The public ID of the image
 * @query width - Target width (optional)
 * @query height - Target height (optional)
 * @query crop - Crop mode (optional)
 * @query quality - Quality setting (optional)
 */
const getTransformedUrl = async (req, res) => {
  try {
    const { publicId, width, height, crop, quality, format } = req.query;

    if (!publicId) {
      return res.status(400).json({
        success: false,
        message: 'No publicId provided',
      });
    }

    const url = cloudinaryService.getTransformedUrl(publicId, {
      width: width ? parseInt(width) : null,
      height: height ? parseInt(height) : null,
      crop: crop || 'fill',
      quality: quality || 'auto',
      format: format || 'auto',
    });

    res.json({
      success: true,
      url,
    });
  } catch (error) {
    console.error('Transform URL error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Get thumbnail URL
 * @route GET /api/cloudinary/thumbnail
 * @query publicId - The public ID of the image
 * @query size - Thumbnail size (optional, default: 150)
 */
const getThumbnailUrl = async (req, res) => {
  try {
    const { publicId, size = 150 } = req.query;

    if (!publicId) {
      return res.status(400).json({
        success: false,
        message: 'No publicId provided',
      });
    }

    const url = cloudinaryService.getThumbnailUrl(publicId, parseInt(size));

    res.json({
      success: true,
      url,
    });
  } catch (error) {
    console.error('Thumbnail URL error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Check Cloudinary configuration status
 * @route GET /api/cloudinary/status
 */
const checkStatus = async (req, res) => {
  try {
    const isConfigured = await cloudinaryService.checkConfiguration();

    res.json({
      success: true,
      configured: isConfigured,
      message: isConfigured ? 'Cloudinary is properly configured' : 'Cloudinary configuration error',
    });
  } catch (error) {
    console.error('Status check error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * Replace an existing image
 * @route PUT /api/cloudinary/replace
 * @body publicId - The public ID of the image to replace
 * @body image - New base64 image
 */
const replaceImage = async (req, res) => {
  try {
    const { publicId, image } = req.body;

    if (!publicId || !image) {
      return res.status(400).json({
        success: false,
        message: 'Both publicId and image are required',
      });
    }

    const result = await cloudinaryService.replaceImage(publicId, image);

    if (result.success) {
      res.json({
        success: true,
        message: 'Image replaced successfully',
        data: {
          url: result.url,
          publicId: result.publicId,
        },
      });
    } else {
      res.status(500).json({
        success: false,
        message: result.error || 'Replace failed',
      });
    }
  } catch (error) {
    console.error('Replace error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  upload,
  uploadFile,
  uploadBase64,
  uploadFromUrl,
  deleteImage,
  deleteMultipleImages,
  getTransformedUrl,
  getThumbnailUrl,
  checkStatus,
  replaceImage,
};
