/**
 * Request logging middleware - Enhanced version with file logging
 */

const { format } = require('date-fns');
const { v4: uuid } = require('uuid');
const fs = require('fs');
const fsPromises = require('fs').promises;
const path = require('path');

const logEvents = async (message, logFileName) => {
    const dateTime = `${format(new Date(), 'yyyyMMdd\tHH:mm:ss')}`;
    const logItem = `${dateTime}\t${uuid()}\t${message}\n`;
    try {
        if (!fs.existsSync(path.join(__dirname, '..', 'logs'))) {
            await fsPromises.mkdir(path.join(__dirname, '..', 'logs'));
        }
        await fsPromises.appendFile(path.join(__dirname, '..', 'logs', logFileName), logItem);
    } catch (err) {
        console.log(err);
    }
};

const logger = (req, res, next) => {
    const timestamp = new Date().toISOString();
    const { method, url } = req;

    // Log to console
    console.log(`[${timestamp}] ${method} ${url}`);

    // Log to file
    logEvents(`${req.method}\t${req.url}\t${req.headers.origin}`, 'reqLog.txt');

    next();
};

module.exports = { logger, logEvents };
