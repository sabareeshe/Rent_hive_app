const Listing = require('../models/Listing');

// @desc    Get all listings (with search & filter)
// @route   GET /api/listings
// @access  Public
const getListings = async (req, res, next) => {
  try {
    const { keyword, search, category, condition, sort } = req.query;
    const searchTerm = keyword || search;

    const query = {};

    if (searchTerm) {
      query.$or = [
        { title: { $regex: searchTerm, $options: 'i' } },
        { description: { $regex: searchTerm, $options: 'i' } },
        { category: { $regex: searchTerm, $options: 'i' } },
      ];
    }

    if (category && category !== 'All') {
      query.category = category;
    }

    if (condition) {
      query.condition = condition;
    }

    query.status = 'available';

    let sortObj = { createdAt: -1 };
    if (sort === 'price_asc') sortObj = { 'rates.daily': 1 };
    if (sort === 'price_desc') sortObj = { 'rates.daily': -1 };
    if (sort === 'rating') sortObj = { averageRating: -1 };

    const listings = await Listing.find(query)
      .populate('owner', 'name avatarUrl')
      .sort(sortObj);

    res.json(listings);
  } catch (error) {
    next(error);
  }
};

// @desc    Get logged in user's listings
// @route   GET /api/listings/my-listings
// @access  Private (Owner)
const getMyListings = async (req, res, next) => {
  try {
    const listings = await Listing.find({ owner: req.user._id })
      .sort({ createdAt: -1 });
    res.json(listings);
  } catch (error) {
    next(error);
  }
};

// @desc    Get listing by ID
// @route   GET /api/listings/:id
// @access  Public
const getListingById = async (req, res, next) => {
  try {
    const listing = await Listing.findById(req.params.id)
      .populate('owner', 'name avatarUrl averageRating totalReviews createdAt');

    if (listing) {
      // Increment views
      listing.views += 1;
      await listing.save();
      res.json(listing);
    } else {
      res.status(404);
      throw new Error('Listing not found');
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Create a listing
// @route   POST /api/listings
// @access  Private (Owner)
const createListing = async (req, res, next) => {
  try {
    let body = req.body;
    if (req.body.data) {
      try {
        body = typeof req.body.data === 'string' ? JSON.parse(req.body.data) : req.body.data;
      } catch (e) {
        body = req.body;
      }
    }

    const {
      title,
      category,
      description,
      condition,
      dailyRate,
      securityDeposit,
      address,
      rates,
      location,
    } = body;

    const rateDaily = (rates && rates.daily !== undefined) ? rates.daily : dailyRate;
    const rateWeekly = (rates && rates.weekly !== undefined) ? rates.weekly : body.weeklyRate;
    const rateMonthly = (rates && rates.monthly !== undefined) ? rates.monthly : body.monthlyRate;

    const images = req.files && req.files.length > 0
      ? req.files.map((file) => file.path)
      : (body.images && body.images.length > 0 ? body.images : ['https://via.placeholder.com/400']);

    const loc = location || {
      address: address || body.pickupAddress || '',
      city: body.city || '',
      state: body.state || '',
      coordinates: [0, 0],
    };

    const listing = new Listing({
      owner: req.user._id,
      title,
      category,
      description,
      condition: condition || 'Good',
      rates: {
        daily: rateDaily,
        weekly: rateWeekly,
        monthly: rateMonthly,
      },
      securityDeposit: securityDeposit || 0,
      images,
      location: loc,
    });

    const createdListing = await listing.save();
    res.status(201).json(createdListing);
  } catch (error) {
    next(error);
  }
};

// @desc    Update a listing
// @route   PUT /api/listings/:id
// @access  Private (Owner)
const updateListing = async (req, res, next) => {
  try {
    const listing = await Listing.findById(req.params.id);

    if (listing) {
      if (listing.owner.toString() !== req.user._id.toString()) {
        res.status(403);
        throw new Error('Not authorized to update this listing');
      }

      let body = req.body;
      if (req.body.data) {
        try {
          body = typeof req.body.data === 'string' ? JSON.parse(req.body.data) : req.body.data;
        } catch (e) {
          body = req.body;
        }
      }

      listing.title = body.title || listing.title;
      listing.category = body.category || listing.category;
      listing.description = body.description || listing.description;
      listing.condition = body.condition || listing.condition;
      
      const rateDaily = (body.rates && body.rates.daily !== undefined) ? body.rates.daily : body.dailyRate;
      if (rateDaily !== undefined) {
        listing.rates.daily = rateDaily;
      }
      if (body.rates?.weekly !== undefined || body.weeklyRate !== undefined) {
        listing.rates.weekly = body.rates?.weekly ?? body.weeklyRate;
      }
      if (body.rates?.monthly !== undefined || body.monthlyRate !== undefined) {
        listing.rates.monthly = body.rates?.monthly ?? body.monthlyRate;
      }
      
      if (body.securityDeposit !== undefined) {
        listing.securityDeposit = body.securityDeposit;
      }
      listing.status = body.status || listing.status;

      if (body.location) {
        listing.location = { ...listing.location, ...body.location };
      } else if (body.pickupAddress || body.city || body.state) {
        listing.location = {
          ...listing.location,
          address: body.pickupAddress || listing.location?.address,
          city: body.city || listing.location?.city,
          state: body.state || listing.location?.state,
        };
      }

      if (req.files && req.files.length > 0) {
        listing.images = req.files.map((file) => file.path);
      } else if (body.images && body.images.length > 0) {
        listing.images = body.images;
      }

      const updatedListing = await listing.save();
      res.json(updatedListing);
    } else {
      res.status(404);
      throw new Error('Listing not found');
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Delete a listing
// @route   DELETE /api/listings/:id
// @access  Private (Owner)
const deleteListing = async (req, res, next) => {
  try {
    const listing = await Listing.findById(req.params.id);

    if (listing) {
      if (listing.owner.toString() !== req.user._id.toString()) {
        res.status(403);
        throw new Error('Not authorized to delete this listing');
      }
      await listing.deleteOne();
      res.json({ message: 'Listing removed' });
    } else {
      res.status(404);
      throw new Error('Listing not found');
    }
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getListings,
  getMyListings,
  getListingById,
  createListing,
  updateListing,
  deleteListing,
};
