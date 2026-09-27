const express = require('express');
const router = express.Router();
const {
  getListings,
  getListingById,
  createListing,
  updateListing,
  deleteListing,
  getMyListings,
} = require('../controllers/listingController');
const { protect, owner } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.route('/')
  .get(getListings)
  .post(protect, owner, upload.array('images', 5), createListing);

router.route('/my-listings')
  .get(protect, owner, getMyListings);

router.route('/:id')
  .get(getListingById)
  .put(protect, owner, upload.array('images', 5), updateListing)
  .delete(protect, owner, deleteListing);

module.exports = router;
