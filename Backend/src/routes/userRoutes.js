const express = require('express');
const router = express.Router();
const { register, login, getCurrentUser } = require('../controllers/authController');
const { updateUserValidator } = require('../middleware/validation');
const {
     updateInfo , 
     getUserinfo ,
     getSingleDependent ,
     addDependent,
     getAllDependents,
} = require('../controllers/userController');


router.patch('/updateInfo',updateUserValidator,updateInfo);
router.get('/getUserInfo',getUserinfo);
router.get('/getSingleDependent',getSingleDependent);
router.post("/addDependent", addDependent);
router.get('/getAllDependents',getAllDependents);

module.exports = router;
