const express = require('express');
const router = express.Router();
const { getEmbedToken } = require('../controllers/powerBiController');
const { authenticateToken, authorizeRole } = require('../middleware/authMiddleware');

/**
 * All Power BI routes are restricted to Admins
 */
// router.use(authenticateToken); // Enable this when your frontend sends JWT
// router.use(authorizeRole('admin'));

router.get('/embed-token/:reportId', getEmbedToken);

module.exports = router;
