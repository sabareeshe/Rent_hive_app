const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const cloudinary = require('../config/cloudinary'); // We will create this

const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'rent_hive',
    allowedFormats: ['jpg', 'png', 'jpeg', 'webp'],
    transformation: [{ width: 1000, height: 1000, crop: 'limit' }],
  },
});

const upload = multer({ storage: storage });

module.exports = upload;
