require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Listing = require('../models/Listing');
const Booking = require('../models/Booking');
const connectDB = require('../config/db');

connectDB();

const importData = async () => {
  try {
    await User.deleteMany();
    await Listing.deleteMany();
    await Booking.deleteMany();

    const createdUsers = await User.create([
      {
        name: 'Admin User',
        username: 'admin',
        email: 'admin@renthive.com',
        password: 'password123',
        role: 'admin',
      },
      {
        name: 'Owner User',
        username: 'owner',
        email: 'owner@renthive.com',
        password: 'password123',
        role: 'owner',
      },
      {
        name: 'Renter User',
        username: 'renter',
        email: 'renter@renthive.com',
        password: 'password123',
        role: 'renter',
      },
    ]);

    const ownerId = createdUsers[1]._id;

    const listings = await Listing.insertMany([
      {
        owner: ownerId,
        title: 'Sony Alpha a7 III',
        category: 'Electronics',
        description: 'Perfect for professional photography.',
        condition: 'Like New',
        rates: { daily: 45 },
        securityDeposit: 500,
        images: ['https://example.com/camera.jpg'],
      },
      {
        owner: ownerId,
        title: 'Mountain Bike',
        category: 'Sports',
        description: 'Great for weekend trails.',
        condition: 'Good',
        rates: { daily: 25 },
        securityDeposit: 100,
        images: ['https://example.com/bike.jpg'],
      }
    ]);

    console.log('Data Imported!');
    process.exit();
  } catch (error) {
    console.error(`Error with data import: ${error}`);
    process.exit(1);
  }
};

const destroyData = async () => {
  try {
    await User.deleteMany();
    await Listing.deleteMany();
    await Booking.deleteMany();

    console.log('Data Destroyed!');
    process.exit();
  } catch (error) {
    console.error(`Error with data destruction: ${error}`);
    process.exit(1);
  }
};

if (process.argv[2] === '-d') {
  destroyData();
} else {
  importData();
}
