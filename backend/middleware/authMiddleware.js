const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      token = req.headers.authorization.split(' ')[1];

      // Decode token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Fetch user and attach to request
      req.user = await User.findById(decoded.id).select('-password');
      if (!req.user) {
        res.status(401);
        return next(new Error('User not found'));
      }

      return next();
    } catch (error) {
      console.error(error);
      res.status(401);
      return next(new Error('Not authorized, token failed'));
    }
  }

  if (!token) {
    res.status(401);
    return next(new Error('Not authorized, no token'));
  }
};

const owner = (req, res, next) => {
  if (req.user && req.user.role === 'owner') {
    next();
  } else {
    res.status(403);
    next(new Error('Not authorized as an owner'));
  }
};

module.exports = { protect, owner };
