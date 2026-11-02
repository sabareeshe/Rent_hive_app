const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const Transaction = require('../models/Transaction');

// @desc    Create new booking
// @route   POST /api/bookings
// @access  Private
const createBooking = async (req, res, next) => {
  try {
    let { item, startDate, endDate, rentalAmount, securityDeposit, platformFee, totalAmount } = req.body;

    const listing = await Listing.findById(item);

    if (!listing) {
      res.status(404);
      throw new Error('Listing not found');
    }

    const start = new Date(startDate);
    const end = new Date(endDate);
    const diffTime = Math.abs(end - start);
    const diffDays = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));

    if (rentalAmount === undefined || rentalAmount === null) {
      rentalAmount = (listing.rates?.daily || 0) * diffDays;
    }
    if (securityDeposit === undefined || securityDeposit === null) {
      securityDeposit = listing.securityDeposit || 0;
    }
    if (platformFee === undefined || platformFee === null) {
      platformFee = Number((rentalAmount * 0.1).toFixed(2));
    }
    if (totalAmount === undefined || totalAmount === null) {
      totalAmount = rentalAmount + securityDeposit + platformFee;
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
      status: 'pending',
    });

    const createdBooking = await booking.save();

    // Increment booking count and revenue on listing
    listing.bookingCount = (listing.bookingCount || 0) + 1;
    listing.revenueGenerated = (listing.revenueGenerated || 0) + rentalAmount;
    await listing.save();

    // Create a transaction record for owner's income
    try {
      await Transaction.create({
        user: listing.owner,
        booking: createdBooking._id,
        type: 'bookingIncome',
        amount: rentalAmount,
        description: `Rental income for booking #${createdBooking._id}`,
        status: 'completed',
      });
    } catch (txError) {
      console.error('Failed to create transaction record:', txError);
    }

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

// @desc    Update booking status (Owner or Renter cancel)
// @route   PUT /api/bookings/:id/status
// @access  Private
const updateBookingStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const booking = await Booking.findById(req.params.id);

    if (booking) {
      const isOwner = booking.owner.toString() === req.user._id.toString();
      const isRenter = booking.renter.toString() === req.user._id.toString();

      if (!isOwner && !(isRenter && status === 'cancelled')) {
        res.status(403);
        throw new Error('Not authorized to update this booking');
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
