const mongoose = require('mongoose');
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
    const { receiverId, conversationId, itemId, text } = req.body;

    let conversation;

    // Check if valid conversationId provided
    if (conversationId && mongoose.Types.ObjectId.isValid(conversationId)) {
      conversation = await Conversation.findById(conversationId);
    }

    // Check by receiverId
    if (!conversation && receiverId && mongoose.Types.ObjectId.isValid(receiverId)) {
      const query = {
        participants: { $all: [req.user._id, receiverId] },
      };
      if (itemId && mongoose.Types.ObjectId.isValid(itemId)) {
        query.item = itemId;
      }
      conversation = await Conversation.findOne(query);

      if (!conversation) {
        const convData = {
          participants: [req.user._id, receiverId],
          lastMessage: text,
        };
        if (itemId && mongoose.Types.ObjectId.isValid(itemId)) {
          convData.item = itemId;
        }
        conversation = await Conversation.create(convData);
      }
    }

    if (!conversation) {
      // Fallback create conversation for user
      conversation = await Conversation.create({
        participants: [req.user._id],
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
