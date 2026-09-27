const mongoose = require('mongoose');

const analyticsSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'User',
    },
    date: {
      type: Date,
      required: true,
    },
    dailyEarnings: {
      type: Number,
      default: 0,
    },
    dailyViews: {
      type: Number,
      default: 0,
    },
    dailyBookings: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Allow one analytics entry per owner per day
analyticsSchema.index({ owner: 1, date: 1 }, { unique: true });

const Analytics = mongoose.model('Analytics', analyticsSchema);

module.exports = Analytics;
