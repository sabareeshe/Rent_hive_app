const Booking = require('../models/Booking');
const Listing = require('../models/Listing');
const Transaction = require('../models/Transaction');

// @desc    Get dashboard summary statistics
// @route   GET /api/owner/dashboard/stats
// @access  Private/Owner
const getDashboardStats = async (req, res, next) => {
  try {
    const ownerId = req.user._id;

    // Active listings count
    const activeListings = await Listing.countDocuments({ owner: ownerId, status: 'available' });

    // Pending requests
    const pendingRequests = await Booking.countDocuments({ owner: ownerId, status: 'pending' });

    // Active rentals
    const activeRentals = await Booking.countDocuments({ owner: ownerId, status: 'active' });

    // Total earnings (sum of completed transactions)
    const earnings = await Transaction.aggregate([
      { $match: { user: ownerId, type: 'bookingIncome', status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);

    const totalEarnings = earnings.length > 0 ? earnings[0].total : 0;

    res.json({
      activeListings,
      pendingRequests,
      activeRentals,
      totalEarnings,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get owner earnings & transactions
// @route   GET /api/owner/earnings
// @access  Private/Owner
const getEarnings = async (req, res, next) => {
  try {
    const transactions = await Transaction.find({ user: req.user._id })
      .populate('booking')
      .sort({ createdAt: -1 });

    const balanceAgg = await Transaction.aggregate([
      { $match: { user: req.user._id, status: 'completed' } },
      {
        $group: {
          _id: null,
          totalIncome: {
            $sum: {
              $cond: [{ $eq: ['$type', 'bookingIncome'] }, '$amount', 0],
            },
          },
          totalWithdrawals: {
            $sum: {
              $cond: [{ $eq: ['$type', 'withdrawal'] }, '$amount', 0],
            },
          },
        },
      },
    ]);

    let availableBalance = 0;
    if (balanceAgg.length > 0) {
      availableBalance = balanceAgg[0].totalIncome - balanceAgg[0].totalWithdrawals;
    }

    res.json({
      availableBalance,
      transactions,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get owner analytics
// @route   GET /api/owner/analytics
// @access  Private/Owner
const getAnalytics = async (req, res, next) => {
  try {
    const filter = req.query.filter || 'Monthly';
    
    // Deterministic mock data for analytics
    let revenue;
    if (filter === 'Weekly') {
      revenue = [
        { label: 'Mon', value: 50 }, { label: 'Tue', value: 120 },
        { label: 'Wed', value: 80 }, { label: 'Thu', value: 200 },
        { label: 'Fri', value: 150 }, { label: 'Sat', value: 300 },
        { label: 'Sun', value: 250 }
      ];
    } else if (filter === 'Monthly') {
      revenue = [
        { label: 'Week 1', value: 400 }, { label: 'Week 2', value: 600 },
        { label: 'Week 3', value: 800 }, { label: 'Week 4', value: 500 }
      ];
    } else {
      revenue = [
        { label: 'Jan', value: 1200 }, { label: 'Feb', value: 1500 },
        { label: 'Mar', value: 1100 }, { label: 'Apr', value: 1800 }
      ];
    }

    res.json({
      revenueTimeline: revenue,
      bookingTrends: [
        { label: 'Requested', value: 15 }, { label: 'Completed', value: 10 }, { label: 'Cancelled', value: 2 }
      ],
      topCategories: [
        { label: 'Cameras', value: 40 }, { label: 'Camping', value: 30 }, { label: 'Tools', value: 30 }
      ],
      listingPerformance: [
        { label: 'Sony A7III', value: 1200 }, { label: '4-Person Tent', value: 600 }, { label: 'Power Drill', value: 150 }
      ],
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Request withdrawal
// @route   POST /api/owner/withdraw
// @access  Private/Owner
const requestWithdrawal = async (req, res, next) => {
  try {
    const { amount, details } = req.body;

    if (!amount || amount <= 0) {
      res.status(400);
      throw new Error('Please provide a valid amount');
    }

    // Check available balance
    const balanceAgg = await Transaction.aggregate([
      { $match: { user: req.user._id, status: 'completed' } },
      {
        $group: {
          _id: null,
          totalIncome: {
            $sum: {
              $cond: [{ $eq: ['$type', 'bookingIncome'] }, '$amount', 0],
            },
          },
          totalWithdrawals: {
            $sum: {
              $cond: [{ $eq: ['$type', 'withdrawal'] }, '$amount', 0],
            },
          },
        },
      },
    ]);

    let availableBalance = 0;
    if (balanceAgg.length > 0) {
      availableBalance = balanceAgg[0].totalIncome - balanceAgg[0].totalWithdrawals;
    }

    if (amount > availableBalance) {
      res.status(400);
      throw new Error('Insufficient balance for withdrawal');
    }

    const transaction = await Transaction.create({
      user: req.user._id,
      type: 'withdrawal',
      amount: amount, 
      description: `Withdrawal requested to ${details}`,
      status: 'completed',
    });

    res.status(201).json(transaction);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getDashboardStats,
  getEarnings,
  getAnalytics,
  requestWithdrawal,
};
