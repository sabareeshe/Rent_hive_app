const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');

// Import middleware
const { errorHandler, notFound } = require('./middleware/errorMiddleware');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Swagger Documentation
try {
  const swaggerDocument = YAML.load(path.join(__dirname, 'docs', 'swagger.yaml'));
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
} catch (e) {
  console.log('Swagger documentation not found or invalid. Skipping /api-docs setup.');
}

// Routes
app.get('/', (req, res) => {
  res.send('RentHive API is running...');
});

// Import route files here
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/listings', require('./routes/listingRoutes'));
app.use('/api/bookings', require('./routes/bookingRoutes'));
app.use('/api/wishlist', require('./routes/wishlistRoutes'));
app.use('/api/chat', require('./routes/chatRoutes'));
app.use('/api/reviews', require('./routes/reviewRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));
app.use('/api/owner', require('./routes/ownerRoutes'));

// Error Handling Middleware
app.use(notFound);
app.use(errorHandler);

module.exports = app;
