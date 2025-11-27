const express = require('express');
const router = express.Router();
const { register, login, getCurrentUser } = require('../controllers/authController');
const { updateUserValidator } = require('../middleware/validation');
const { updateInfo , getUserinfo} = require('../controllers/userController');


router.patch('/updateInfo',updateUserValidator,updateInfo);
router.get('/getUserInfo',getUserinfo);

module.exports = router;
