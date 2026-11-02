const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../config/cloudinary');

let storage;
const hasCloudinary = process.env.CLOUDINARY_CLOUD_NAME && 
  process.env.CLOUDINARY_CLOUD_NAME !== 'your_cloud_name' &&
  process.env.CLOUDINARY_API_KEY && 
  process.env.CLOUDINARY_API_KEY !== 'your_api_key';

if (hasCloudinary) {
  storage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
      folder: 'rent_hive',
      allowedFormats: ['jpg', 'png', 'jpeg', 'webp'],
      transformation: [{ width: 1000, height: 1000, crop: 'limit' }],
    },
  });
} else {
  // Local disk storage fallback
  const uploadDir = path.join(__dirname, '..', 'uploads');
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
  }
  storage = multer.diskStorage({
    destination: (req, file, cb) => {
      cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
      const ext = path.extname(file.originalname) || '.jpg';
      cb(null, `${file.fieldname}-${uniqueSuffix}${ext}`);
    },
  });
}

const upload = multer({ storage: storage });

module.exports = upload;
