/**
 * Express server setup
 */

const express = require('express');
const logger = require('./middleware/logger');
const errorHandler = require('./middleware/errorHandler');
const userRoutes = require('./routes/userRoutes');

const app = express();

// Middleware
app.use(express.json());
app.use(logger);

// Routes
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy', timestamp: new Date() });
});

app.use('/api/users', userRoutes);

// Error handling
app.use(errorHandler);

module.exports = app;
