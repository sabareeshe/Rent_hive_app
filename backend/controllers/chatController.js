const Conversation = require('../models/Conversation');
const Message = require('../models/Message');

// @desc    Get all conversations for a user
// @route   GET /api/chat/conversations
// @access  Private
const getConversations = async (req, res, next) => {
  try {
    const conversations = await Conversation.find({ participants: req.user._id })
      .populate('participants', 'name avatarUrl')
      .populate('item', 'title images')
      .sort({ lastMessageAt: -1 });

    res.json(conversations);
  } catch (error) {
    next(error);
  }
};

// @desc    Get messages for a conversation
// @route   GET /api/chat/conversations/:id/messages
// @access  Private
const getMessages = async (req, res, next) => {
  try {
    const messages = await Message.find({ conversationId: req.params.id })
      .populate('senderId', 'name avatarUrl')
      .sort({ createdAt: 1 });

    res.json(messages);
  } catch (error) {
    next(error);
  }
};

// @desc    Send a message
// @route   POST /api/chat/messages
// @access  Private
const sendMessage = async (req, res, next) => {
  try {
    const { receiverId, itemId, text } = req.body;

    // Check if conversation exists
    let conversation = await Conversation.findOne({
      participants: { $all: [req.user._id, receiverId] },
      item: itemId,
    });

    if (!conversation) {
      conversation = await Conversation.create({
        participants: [req.user._id, receiverId],
        item: itemId,
        lastMessage: text,
      });
    } else {
      conversation.lastMessage = text;
      conversation.lastMessageAt = Date.now();
      await conversation.save();
    }

    const message = await Message.create({
      conversationId: conversation._id,
      senderId: req.user._id,
      text,
    });

    res.status(201).json(message);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getConversations,
  getMessages,
  sendMessage,
};
