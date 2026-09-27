const Booking = require('../models/Booking');
const Listing = require('../models/Listing');

// @desc    Create new booking
// @route   POST /api/bookings
// @access  Private
const createBooking = async (req, res, next) => {
  try {
    const { item, startDate, endDate, rentalAmount, securityDeposit, platformFee, totalAmount } = req.body;

    const listing = await Listing.findById(item);

    if (!listing) {
      res.status(404);
      throw new Error('Listing not found');
    }

    const booking = new Booking({
      item,
      renter: req.user._id,
      owner: listing.owner,
      startDate,
      endDate,
      rentalAmount,
      securityDeposit,
      platformFee,
      totalAmount,
    });

    const createdBooking = await booking.save();

    // Increment booking count on listing
    listing.bookingCount += 1;
    listing.revenueGenerated += rentalAmount;
    await listing.save();

    res.status(201).json(createdBooking);
  } catch (error) {
    next(error);
  }
};

// @desc    Get user bookings
// @route   GET /api/bookings/mybookings
// @access  Private
const getMyBookings = async (req, res, next) => {
  try {
    const bookings = await Booking.find({ renter: req.user._id })
      .populate('item', 'title images rates')
      .populate('owner', 'name avatarUrl')
      .sort({ createdAt: -1 });

    res.json(bookings);
  } catch (error) {
    next(error);
  }
};

// @desc    Get booking by ID
// @route   GET /api/bookings/:id
// @access  Private
const getBookingById = async (req, res, next) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('item', 'title images rates')
      .populate('renter', 'name email avatarUrl')
      .populate('owner', 'name email avatarUrl');

    if (booking) {
      // Ensure only owner or renter can view
      if (
        booking.renter._id.toString() !== req.user._id.toString() &&
        booking.owner._id.toString() !== req.user._id.toString()
      ) {
        res.status(403);
        throw new Error('Not authorized to view this booking');
      }
      res.json(booking);
    } else {
      res.status(404);
      throw new Error('Booking not found');
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Update booking status (Owner)
// @route   PUT /api/bookings/:id/status
// @access  Private/Owner
const updateBookingStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const booking = await Booking.findById(req.params.id);

    if (booking) {
      if (booking.owner.toString() !== req.user._id.toString()) {
        res.status(403);
        throw new Error('Not authorized');
      }

      booking.status = status;
      const updatedBooking = await booking.save();
      res.json(updatedBooking);
    } else {
      res.status(404);
      throw new Error('Booking not found');
    }
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createBooking,
  getMyBookings,
  getBookingById,
  updateBookingStatus,
};
