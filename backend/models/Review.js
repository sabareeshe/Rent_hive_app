const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    item: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'Listing',
    },
    author: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'User',
    },
    targetUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User', // If it's a review about the owner
    },
    booking: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'Booking',
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    comment: {
      type: String,
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

// Prevent duplicate reviews for the same booking
reviewSchema.index({ booking: 1, author: 1 }, { unique: true });

const Review = mongoose.model('Review', reviewSchema);

module.exports = Review;
