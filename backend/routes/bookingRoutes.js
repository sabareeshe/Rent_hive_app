const express = require('express');
const router = express.Router();
const {
  createBooking,
  getMyBookings,
  getBookingById,
  updateBookingStatus,
} = require('../controllers/bookingController');
const { protect, owner } = require('../middleware/authMiddleware');

router.route('/')
  .post(protect, createBooking);

router.route('/my-bookings')
  .get(protect, getMyBookings);

router.route('/:id')
  .get(protect, getBookingById);

router.route('/:id/status')
  .put(protect, owner, updateBookingStatus);

module.exports = router;
