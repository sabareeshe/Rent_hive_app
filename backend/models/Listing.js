const mongoose = require('mongoose');

const listingSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'User',
    },
    title: {
      type: String,
      required: true,
    },
    category: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    condition: {
      type: String,
      required: true,
    },
    rates: {
      hourly: Number,
      daily: {
        type: Number,
        required: true,
      },
      weekly: Number,
    },
    securityDeposit: {
      type: Number,
      required: true,
    },
    images: [
      {
        type: String,
        required: true,
      },
    ],
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        default: [0, 0],
      },
      address: String,
    },
    status: {
      type: String,
      enum: ['available', 'booked', 'paused', 'archived'],
      default: 'available',
    },
    averageRating: {
      type: Number,
      default: 0,
    },
    totalReviews: {
      type: Number,
      default: 0,
    },
    views: {
      type: Number,
      default: 0,
    },
    wishlistCount: {
      type: Number,
      default: 0,
    },
    bookingCount: {
      type: Number,
      default: 0,
    },
    revenueGenerated: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

listingSchema.index({ location: '2dsphere' });
listingSchema.index({ title: 'text', description: 'text' });

const Listing = mongoose.model('Listing', listingSchema);

module.exports = Listing;
