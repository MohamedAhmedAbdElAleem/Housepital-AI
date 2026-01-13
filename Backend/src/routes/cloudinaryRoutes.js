const express = require('express');
const router = express.Router();
const { upload, uploadFile } = require('../controllers/cloudinaryController');

router.post('/uploadFile', upload.single('file'), uploadFile);

module.exports = router;
