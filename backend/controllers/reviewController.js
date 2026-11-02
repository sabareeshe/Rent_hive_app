const mongoose = require('mongoose');
const Review = require('../models/Review');
const Listing = require('../models/Listing');
const User = require('../models/User');
const Booking = require('../models/Booking');

// @desc    Get reviews for a listing
// @route   GET /api/reviews/listing/:id
// @access  Public
const getListingReviews = async (req, res, next) => {
  try {
    const reviews = await Review.find({ item: req.params.id })
      .populate('author', 'name avatarUrl')
      .sort({ createdAt: -1 });

    res.json(reviews);
  } catch (error) {
    next(error);
  }
};

// @desc    Add review to listing
// @route   POST /api/reviews
// @access  Private
const addReview = async (req, res, next) => {
  try {
    const { item, bookingId, rating, comment } = req.body;

    let targetOwnerId;
    let validBookingId = null;

    if (bookingId && mongoose.Types.ObjectId.isValid(bookingId)) {
      const booking = await Booking.findById(bookingId);
      if (booking) {
        validBookingId = booking._id;
        targetOwnerId = booking.owner;
      }
    }

    const listing = await Listing.findById(item);
    if (!targetOwnerId && listing) {
      targetOwnerId = listing.owner;
    }

    const reviewData = {
      item,
      author: req.user._id,
      rating: Number(rating) || 5,
      comment,
      targetUser: targetOwnerId,
    };
    if (validBookingId) {
      reviewData.booking = validBookingId;
    }

    const review = await Review.create(reviewData);

    // Update Listing Rating
    if (listing) {
      listing.totalReviews = (listing.totalReviews || 0) + 1;
      listing.averageRating = ((listing.averageRating * (listing.totalReviews - 1)) + Number(rating)) / listing.totalReviews;
      await listing.save();
    }

    // Update Owner Rating
    if (targetOwnerId) {
      const owner = await User.findById(targetOwnerId);
      if (owner) {
        owner.totalReviews = (owner.totalReviews || 0) + 1;
        owner.averageRating = ((owner.averageRating * (owner.totalReviews - 1)) + Number(rating)) / owner.totalReviews;
        await owner.save();
      }
    }

    res.status(201).json(review);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getListingReviews,
  addReview,
};
