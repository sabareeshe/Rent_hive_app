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

    const booking = await Booking.findById(bookingId);
    if (!booking || booking.status !== 'completed') {
      res.status(400);
      throw new Error('Can only review completed bookings');
    }

    const review = await Review.create({
      item,
      author: req.user._id,
      booking: bookingId,
      rating,
      comment,
      targetUser: booking.owner, // Also leaves a review for the owner implicitly
    });

    // Update Listing Rating
    const listing = await Listing.findById(item);
    if (listing) {
      listing.totalReviews += 1;
      listing.averageRating = ((listing.averageRating * (listing.totalReviews - 1)) + rating) / listing.totalReviews;
      await listing.save();
    }

    // Update Owner Rating
    const owner = await User.findById(booking.owner);
    if (owner) {
      owner.totalReviews += 1;
      owner.averageRating = ((owner.averageRating * (owner.totalReviews - 1)) + rating) / owner.totalReviews;
      await owner.save();
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
