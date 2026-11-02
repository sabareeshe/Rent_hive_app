const User = require('../models/User');

// @desc    Get user profile
// @route   GET /api/users/profile
// @access  Private
const getUserProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).select('-password');

    if (user) {
      res.json(user);
    } else {
      res.status(404);
      throw new Error('User not found');
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
const updateUserProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);

    if (user) {
      if (req.body.name !== undefined) user.name = req.body.name;
      if (req.body.username !== undefined) user.username = req.body.username;
      if (req.body.phone !== undefined) user.phone = req.body.phone;
      if (req.body.address !== undefined) user.address = req.body.address;
      if (req.body.city !== undefined) user.city = req.body.city;
      if (req.body.state !== undefined) user.state = req.body.state;
      if (req.body.pincode !== undefined) user.pincode = req.body.pincode;
      if (req.body.bio !== undefined) user.bio = req.body.bio;
      
      if (req.file) {
        user.avatarUrl = req.file.path.startsWith('http') 
          ? req.file.path.replace('http://', 'https://')
          : `https://${req.get('host')}/uploads/${req.file.filename}`;
      } else if (req.body.avatarUrl) {
        user.avatarUrl = req.body.avatarUrl;
      }

      if (req.body.password) {
        user.password = req.body.password;
      }

      const updatedUser = await user.save();
      const userObj = updatedUser.toObject();
      delete userObj.password;

      res.json(userObj);
    } else {
      res.status(404);
      throw new Error('User not found');
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Get user by ID
// @route   GET /api/users/:id
// @access  Public
const getUserById = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (user) {
      res.json(user);
    } else {
      res.status(404);
      throw new Error('User not found');
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Delete user account
// @route   DELETE /api/users/profile
// @access  Private
const deleteUserProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);

    if (user) {
      await user.deleteOne();
      res.json({ message: 'User removed' });
    } else {
      res.status(404);
      throw new Error('User not found');
    }
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getUserProfile,
  getUserById,
  updateUserProfile,
  deleteUserProfile,
};
