/**
 * Cloudinary Service - Centralized Image Management
 * 
 * This service handles all image operations:
 * - Upload (from file, base64, URL)
 * - Delete
 * - Transform (resize, crop, format)
 * - Get optimized URLs
 * 
 * Usage Examples:
 * - Profile pictures
 * - National ID documents
 * - Medical records/PDFs
 * - Any other images in the app
 */

// Note: dotenv is already loaded in server.js
const cloudinary = require('cloudinary').v2;

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

// Log Cloudinary configuration status
console.log('☁️ Cloudinary Config:', {
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME ? '✅ ' + process.env.CLOUDINARY_CLOUD_NAME : '❌ Missing',
  api_key: process.env.CLOUDINARY_API_KEY ? '✅ Set' : '❌ Missing',
  api_secret: process.env.CLOUDINARY_API_SECRET ? '✅ Set' : '❌ Missing',
});

/**
 * Folder structure in Cloudinary:
 * housepital/
 *   ├── profiles/          - User profile pictures
 *   ├── id-documents/      - National ID cards (front/back)
 *   ├── medical-records/   - Medical documents, PDFs
 *   ├── prescriptions/     - Prescription images
 *   └── general/           - Other images
 */
const FOLDERS = {
  PROFILES: 'housepital/profiles',
  ID_DOCUMENTS: 'housepital/id-documents',
  MEDICAL_RECORDS: 'housepital/medical-records',
  PRESCRIPTIONS: 'housepital/prescriptions',
  GENERAL: 'housepital/general',
};

/**
 * Upload image from base64 string
 * @param {string} base64String - The base64 encoded image (with or without data URI prefix)
 * @param {object} options - Upload options
 * @param {string} options.folder - Cloudinary folder (use FOLDERS constant)
 * @param {string} options.publicId - Custom public ID (optional)
 * @param {string} options.resourceType - 'image', 'raw', or 'auto' (default: 'auto')
 * @param {object} options.transformation - Transformation options
 * @returns {Promise<object>} - Upload result with url and publicId
 */
const uploadFromBase64 = async (base64String, options = {}) => {
  try {
    const {
      folder = FOLDERS.GENERAL,
      publicId = null,
      resourceType = 'auto',
      transformation = null,
    } = options;

    // Add data URI prefix if not present
    let dataUri = base64String;
    if (!base64String.startsWith('data:')) {
      // Try to detect the image type from base64
      const signatures = {
        '/9j/': 'image/jpeg',
        'iVBORw0KGgo': 'image/png',
        'R0lGODlh': 'image/gif',
        'UklGR': 'image/webp',
        'JVBERi0': 'application/pdf',
      };
      
      let mimeType = 'image/jpeg'; // default
      for (const [signature, mime] of Object.entries(signatures)) {
        if (base64String.startsWith(signature)) {
          mimeType = mime;
          break;
        }
      }
      dataUri = `data:${mimeType};base64,${base64String}`;
    }

    const uploadOptions = {
      folder,
      resource_type: resourceType,
      ...(publicId && { public_id: publicId }),
      ...(transformation && { transformation }),
    };

    console.log('📤 Uploading to Cloudinary...', { folder, resourceType });
    const result = await cloudinary.uploader.upload(dataUri, uploadOptions);
    console.log('✅ Upload successful:', { url: result.secure_url, publicId: result.public_id });

    return {
      success: true,
      url: result.secure_url,
      publicId: result.public_id,
      format: result.format,
      width: result.width,
      height: result.height,
      bytes: result.bytes,
      resourceType: result.resource_type,
    };
  } catch (error) {
    console.error('❌ Cloudinary upload error:', error);
    return {
      success: false,
      error: error.message,
    };
  }
};

/**
 * Upload image from buffer (for multer uploads)
 * @param {Buffer} buffer - The file buffer
 * @param {object} options - Upload options
 * @returns {Promise<object>} - Upload result
 */
const uploadFromBuffer = async (buffer, options = {}) => {
  try {
    console.log('📤 uploadFromBuffer called, buffer size:', buffer?.length);
    
    const {
      folder = FOLDERS.GENERAL,
      publicId = null,
      resourceType = 'auto',
      transformation = null,
    } = options;

    console.log('📂 Upload options:', { folder, publicId, resourceType });

    const result = await new Promise((resolve, reject) => {
      const uploadOptions = {
        folder,
        resource_type: resourceType,
        ...(publicId && { public_id: publicId }),
        ...(transformation && { transformation }),
      };

      console.log('☁️ Calling cloudinary.uploader.upload_stream...');
      const stream = cloudinary.uploader.upload_stream(
        uploadOptions,
        (error, result) => {
          if (error) {
            console.log('❌ Stream error:', error);
            reject(error);
          } else {
            console.log('✅ Stream success:', result?.secure_url);
            resolve(result);
          }
        }
      );
      stream.end(buffer);
    });

    console.log('✅ Upload complete:', result.secure_url);

    return {
      success: true,
      url: result.secure_url,
      publicId: result.public_id,
      format: result.format,
      width: result.width,
      height: result.height,
      bytes: result.bytes,
      resourceType: result.resource_type,
    };
  } catch (error) {
    console.error('❌ Cloudinary buffer upload error:', error);
    return {
      success: false,
      error: error.message,
    };
  }
};

/**
 * Upload image from URL
 * @param {string} imageUrl - The URL of the image to upload
 * @param {object} options - Upload options
 * @returns {Promise<object>} - Upload result
 */
const uploadFromUrl = async (imageUrl, options = {}) => {
  try {
    const {
      folder = FOLDERS.GENERAL,
      publicId = null,
      resourceType = 'auto',
    } = options;

    const result = await cloudinary.uploader.upload(imageUrl, {
      folder,
      resource_type: resourceType,
      ...(publicId && { public_id: publicId }),
    });

    return {
      success: true,
      url: result.secure_url,
      publicId: result.public_id,
      format: result.format,
    };
  } catch (error) {
    console.error('Cloudinary URL upload error:', error);
    return {
      success: false,
      error: error.message,
    };
  }
};

/**
 * Delete image from Cloudinary
 * @param {string} publicId - The public ID of the image to delete
 * @param {string} resourceType - 'image', 'raw', or 'video' (default: 'image')
 * @returns {Promise<object>} - Deletion result
 */
const deleteImage = async (publicId, resourceType = 'image') => {
  try {
    const result = await cloudinary.uploader.destroy(publicId, {
      resource_type: resourceType,
    });

    return {
      success: result.result === 'ok',
      result: result.result,
    };
  } catch (error) {
    console.error('Cloudinary delete error:', error);
    return {
      success: false,
      error: error.message,
    };
  }
};

/**
 * Delete multiple images from Cloudinary
 * @param {string[]} publicIds - Array of public IDs to delete
 * @param {string} resourceType - 'image', 'raw', or 'video' (default: 'image')
 * @returns {Promise<object>} - Deletion result
 */
const deleteMultipleImages = async (publicIds, resourceType = 'image') => {
  try {
    const result = await cloudinary.api.delete_resources(publicIds, {
      resource_type: resourceType,
    });

    return {
      success: true,
      deleted: result.deleted,
      notFound: result.not_found || [],
    };
  } catch (error) {
    console.error('Cloudinary bulk delete error:', error);
    return {
      success: false,
      error: error.message,
    };
  }
};

/**
 * Get optimized/transformed image URL
 * @param {string} publicId - The public ID of the image
 * @param {object} transformations - Transformation options
 * @returns {string} - Transformed image URL
 */
const getTransformedUrl = (publicId, transformations = {}) => {
  const {
    width = null,
    height = null,
    crop = 'fill',
    quality = 'auto',
    format = 'auto',
    effect = null,
  } = transformations;

  const options = {
    quality,
    fetch_format: format,
    ...(width && { width }),
    ...(height && { height }),
    ...(width || height ? { crop } : {}),
    ...(effect && { effect }),
  };

  return cloudinary.url(publicId, options);
};

/**
 * Get thumbnail URL
 * @param {string} publicId - The public ID of the image
 * @param {number} size - Thumbnail size (default: 150)
 * @returns {string} - Thumbnail URL
 */
const getThumbnailUrl = (publicId, size = 150) => {
  return cloudinary.url(publicId, {
    width: size,
    height: size,
    crop: 'thumb',
    gravity: 'face',
    quality: 'auto',
    fetch_format: 'auto',
  });
};

/**
 * Get profile picture URL with face detection
 * @param {string} publicId - The public ID of the image
 * @param {number} size - Image size (default: 200)
 * @returns {string} - Optimized profile picture URL
 */
const getProfilePictureUrl = (publicId, size = 200) => {
  return cloudinary.url(publicId, {
    width: size,
    height: size,
    crop: 'fill',
    gravity: 'face',
    quality: 'auto',
    fetch_format: 'auto',
    radius: 'max', // Circular
  });
};

/**
 * Get ID document URL (optimized for readability)
 * @param {string} publicId - The public ID of the image
 * @returns {string} - Optimized ID document URL
 */
const getIdDocumentUrl = (publicId) => {
  return cloudinary.url(publicId, {
    quality: 'auto:best',
    fetch_format: 'auto',
  });
};

/**
 * Replace an existing image (update)
 * @param {string} publicId - The public ID of the image to replace
 * @param {string} newBase64 - The new image in base64
 * @returns {Promise<object>} - Upload result
 */
const replaceImage = async (publicId, newBase64) => {
  try {
    // Delete old image
    await deleteImage(publicId);
    
    // Upload new image with same public ID structure
    const folder = publicId.substring(0, publicId.lastIndexOf('/'));
    const result = await uploadFromBase64(newBase64, { folder });
    
    return result;
  } catch (error) {
    console.error('Cloudinary replace error:', error);
    return {
      success: false,
      error: error.message,
    };
  }
};

/**
 * Check if Cloudinary is properly configured
 * @returns {Promise<boolean>} - Configuration status
 */
const checkConfiguration = async () => {
  try {
    await cloudinary.api.ping();
    return true;
  } catch (error) {
    console.error('Cloudinary configuration error:', error);
    return false;
  }
};

/**
 * Extract public ID from Cloudinary URL
 * @param {string} url - Cloudinary URL
 * @returns {string|null} - Public ID or null
 */
const extractPublicId = (url) => {
  try {
    if (!url || !url.includes('cloudinary.com')) return null;
    
    // Extract the public ID from URL
    // Format: https://res.cloudinary.com/{cloud_name}/image/upload/{version}/{public_id}.{format}
    const regex = /\/upload\/(?:v\d+\/)?(.+)\.[a-zA-Z]+$/;
    const match = url.match(regex);
    
    return match ? match[1] : null;
  } catch (error) {
    return null;
  }
};

module.exports = {
  // Constants
  FOLDERS,
  
  // Upload methods
  uploadFromBase64,
  uploadFromBuffer,
  uploadFromUrl,
  
  // Delete methods
  deleteImage,
  deleteMultipleImages,
  
  // URL methods
  getTransformedUrl,
  getThumbnailUrl,
  getProfilePictureUrl,
  getIdDocumentUrl,
  
  // Update methods
  replaceImage,
  
  // Utility methods
  checkConfiguration,
  extractPublicId,
  
  // Direct cloudinary access (for advanced usage)
  cloudinary,
};
