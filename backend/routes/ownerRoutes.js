const express = require('express');
const router = express.Router();
const { getDashboardStats, getEarnings, getAnalytics, requestWithdrawal } = require('../controllers/ownerController');
const { protect, owner } = require('../middleware/authMiddleware');

router.route('/dashboard/stats')
  .get(protect, owner, getDashboardStats);

router.route('/earnings')
  .get(protect, owner, getEarnings);

router.route('/analytics')
  .get(protect, owner, getAnalytics);

router.route('/withdraw')
  .post(protect, owner, requestWithdrawal);

module.exports = router;
