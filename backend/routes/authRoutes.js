const express = require('express');
const router = express.Router();
const { registerUser, loginUser, logoutUser, forgotPassword, resetPassword } = require('../controllers/authController');
const { registerValidation, loginValidation } = require('../validations/authValidations');
const { validateRequest } = require('../middleware/validateMiddleware');
const { protect } = require('../middleware/authMiddleware');

router.post('/register', registerValidation, validateRequest, registerUser);
router.post('/login', loginValidation, validateRequest, loginUser);
router.post('/logout', protect, logoutUser);
router.post('/forgotpassword', forgotPassword);
router.put('/resetpassword/:resettoken', resetPassword);

module.exports = router;
