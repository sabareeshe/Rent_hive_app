const express = require('express');
const router = express.Router();
const { getConversations, getMessages, sendMessage } = require('../controllers/chatController');
const { protect } = require('../middleware/authMiddleware');

router.route('/conversations').get(protect, getConversations);
router.route('/conversations/:id/messages').get(protect, getMessages);
router.route('/messages').post(protect, sendMessage);

module.exports = router;
