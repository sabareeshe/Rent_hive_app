const express = require('express');
const router = express.Router();
const { getListingReviews, addReview } = require('../controllers/reviewController');
const { protect } = require('../middleware/authMiddleware');

router.route('/')
  .post(protect, addReview);

router.route('/listing/:id')
  .get(getListingReviews);

module.exports = router;
