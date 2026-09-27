const express = require('express');
const router = express.Router();
const { getDashboardStats, getEarnings, getAnalytics, requestWithdrawal } = require('../controllers/ownerController');
const { protect, owner } = require('../middleware/authMiddleware');

router.route('/dashboard/stats')
  .get(protect, getDashboardStats);

router.route('/earnings')
  .get(protect, getEarnings);

router.route('/analytics')
  .get(protect, getAnalytics);

router.route('/withdraw')
  .post(protect, requestWithdrawal);

module.exports = router;
