const Listing = require('../models/Listing');

// @desc    Get all listings (with search & filter)
// @route   GET /api/listings
// @access  Public
const getListings = async (req, res, next) => {
  try {
    const { keyword, category, condition, sort } = req.query;

    const query = {};

    if (keyword) {
      query.$text = { $search: keyword };
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
    const { title, category, description, condition, dailyRate, securityDeposit, address } = req.body;

    const images = req.files ? req.files.map((file) => file.path) : [];

    const listing = new Listing({
      owner: req.user._id,
      title,
      category,
      description,
      condition,
      rates: {
        daily: dailyRate,
      },
      securityDeposit,
      images: images.length > 0 ? images : ['https://via.placeholder.com/400'], // fallback
      address,
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

      listing.title = req.body.title || listing.title;
      listing.category = req.body.category || listing.category;
      listing.description = req.body.description || listing.description;
      listing.condition = req.body.condition || listing.condition;
      
      if (req.body.dailyRate) {
        listing.rates.daily = req.body.dailyRate;
      }
      
      listing.securityDeposit = req.body.securityDeposit || listing.securityDeposit;
      listing.status = req.body.status || listing.status;

      if (req.files && req.files.length > 0) {
        listing.images = req.files.map((file) => file.path);
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
