require('dotenv').config();
const axios = require('axios');

const BASE_URL = process.env.TEXTBEE_BASE_URL || 'https://api.textbee.dev/api/v1';
const API_KEY = process.env.TEXTBEE_API_KEY;
const DEVICE_ID = process.env.TEXTBEE_DEVICE_ID;


/***

to use do this

const result = await sendSMS(['+number'], 'message');

 ***/


async function sendSMS(recipients, message) {
    
  if (!Array.isArray(recipients) || recipients.length === 0) {
    throw new Error('Recipients must be a non-empty array of phone numbers.');
  }

  const invalidNumbers = recipients.filter(num => !/^\+\d{10,15}$/.test(num));
  if (invalidNumbers.length > 0) {
    throw new Error(`Invalid phone numbers: ${invalidNumbers.join(', ')}`);
  }

  if (typeof message !== 'string' || message.trim().length === 0) {
    throw new Error('Message cannot be empty.');
  }

  try {
    const response = await axios.post(
      `${BASE_URL}/gateway/devices/${DEVICE_ID}/send-sms`,
      { recipients, message },
      { headers: { 'x-api-key': API_KEY } }
    );

    return response.data;
  } catch (error) {
    throw new Error(`Failed to send SMS: ${error.response?.data?.message || error.message}`);
  }
}


module.exports = { sendSMS };
