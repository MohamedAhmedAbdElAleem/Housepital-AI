
const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/authMiddleware');
const {
    getAllClinics,
    addClinic,
    getMyClinics,
    updateClinic,
    deleteClinic
} = require('../controllers/clinicController');

// PUBLIC route (no auth needed)
router.get('/', getAllClinics);

// Protected routes (require authentication)
router.use(authenticateToken);

router.post('/', addClinic);
router.get('/my-clinics', getMyClinics);
router.put('/:id', updateClinic);
router.delete('/:id', deleteClinic);

module.exports = router;
