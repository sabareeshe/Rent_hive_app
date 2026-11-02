const express = require('express');
const router = express.Router();
const { getUserProfile, getUserById, updateUserProfile, deleteUserProfile } = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router
  .route('/profile')
  .get(protect, getUserProfile)
  .put(protect, upload.single('avatar'), updateUserProfile)
  .delete(protect, deleteUserProfile);

router.route('/:id').get(getUserById);

module.exports = router;
