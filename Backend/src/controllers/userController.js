/**
 * User controller - Combined version with both test functions and production MongoDB functions
 */

const User = require('../models/User');
const Dependent = require("../models/Dependent");
const { logEvents } = require('../middleware/logger');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// In-memory storage for testing purposes
const users = [];

// Test helper functions (for unit/integration tests)
const clearUsers = () => {
  users.length = 0;
};

// Test controller functions (used by tests)
const registerUser = (req, res) => {
  const { email, password, name } = req.body;

  // Check if user already exists
  const existingUser = users.find((user) => user.email === email);
  if (existingUser) {
    return res.status(409).json({
      success: false,
      error: 'User already exists',
    });
  }

  // Create new user
  const newUser = {
    id: users.length + 1,
    email,
    name,
    password,
    createdAt: new Date(),
  };

  users.push(newUser);

  // Return user without password
  const { password: _, ...userWithoutPassword } = newUser;

  res.status(201).json({
    success: true,
    data: userWithoutPassword,
  });
};

const loginUser = (req, res) => {
  const { email, password } = req.body;

  // Find user
  const user = users.find((u) => u.email === email && u.password === password);

  if (!user) {
    return res.status(401).json({
      success: false,
      error: 'Invalid credentials',
    });
  }

  // Return user without password
  const { password: _, ...userWithoutPassword } = user;

  res.status(200).json({
    success: true,
    data: userWithoutPassword,
    token: 'mock-jwt-token',
  });
};

const getAllUsers = (req, res) => {
  // Remove passwords from response
  const usersWithoutPasswords = users.map(({ password, ...user }) => user);

  res.status(200).json({
    success: true,
    count: users.length,
    data: usersWithoutPasswords,
  });
};

const getUserById = (req, res) => {
  const { id } = req.params;
  const user = users.find((u) => u.id === parseInt(id, 10));

  if (!user) {
    return res.status(404).json({
      success: false,
      error: 'User not found',
    });
  }

  const { password: _, ...userWithoutPassword } = user;

  res.status(200).json({
    success: true,
    data: userWithoutPassword,
  });
};

// Production MongoDB functions
const updateInfo = async (req, res) => {
  try {
    const id = req.body.id;
    const data = req.body;

    const fields = Object.keys(User.schema.paths).filter(f => !["_id", "__v"].includes(f));

    const updateData = {};
    for (const key in data) {
      if (fields.includes(key)) {
        updateData[key] = data[key];
      }
    }

    if ("password" in data) {
      const password = data.password;
      const salt = await bcrypt.genSalt(12);
      updateData.password_hash = await bcrypt.hash(password, salt);
      updateData.salt = salt;
      delete updateData.password;
    }

    const updatedUser = await User.findByIdAndUpdate(
      id,
      { $set: updateData },
      { new: true, runValidators: true }
    );

    return res.status(200).json(updatedUser);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Something went wrong" });
  }
};

const getUserinfo = async (req, res) => {
  try {
    const id = req.body.id;
    if (!id) return res.status(400).json({ message: "No ID provided" });

    const user = await User.findById(id);

    if (!user) return res.status(404).json({ message: "User not found" });

    return res.status(200).json(user);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Something went wrong" });
  }
};

const getSingleDependent = async (req, res) => {
  const id = req.body._id || req.body.id;
  if (!id) return res.status(400).json({ message: "No ID provided" });

  const dependentId = req.body.dependentId;

  try {
    const dependentUser = await Dependent.findOne({
      responsibleUser: id,
      _id: dependentId
    });
    if (!dependentUser) return res.status(404).json({ message: "This person is not found" });

    return res.status(200).json(dependentUser);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "An error occurred" });
  }
};

const addDependent = async (req, res) => {
  try {
    const userId = req.body._id || req.body.id;

    const {
      fullName,
      relationship,
      dateOfBirth,
      gender,
      mobile,
      chronicConditions,
      allergies,
      nationalId,
      birthCertificateId,
      responsibleUser
    } = req.body;

    if (!nationalId && !birthCertificateId) {
      return res.status(400).json({
        message: "Either national ID or birth certificate ID is required"
      });
    }

    const newDependent = new Dependent({
      fullName,
      relationship,
      dateOfBirth,
      gender,
      mobile,
      chronicConditions,
      allergies,
      nationalId,
      birthCertificateId,
      responsibleUser
    });

    await newDependent.save();

    return res.status(201).json({
      success: true,
      message: "Dependent added successfully",
      dependent: newDependent
    });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: err.message });
  }
};

const getAllDependents = async (req, res) => {
  const id = req.body._id || req.body.id;
  if (!id) return res.status(400).json("No ID provided");

  try {
    const dependents = await Dependent.find({ responsibleUser: id });
    return res.status(200).json(dependents);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ message: "An error occurred", error: err.message });
  }
};

module.exports = {
  // Test functions
  registerUser,
  loginUser,
  getAllUsers,
  getUserById,
  clearUsers,
  // Production functions
  updateInfo,
  getUserinfo,
  getSingleDependent,
  addDependent,
  getAllDependents,
};
