const { Redis } = require('@upstash/redis');

let redisInstance = null;

const createRedisClient = () => {
  if (redisInstance) return redisInstance;

  redisInstance = new Redis({
    // url: process.env.UPSTASH_REDIS_REST_URL, 
    // token: process.env.UPSTASH_REDIS_REST_TOKEN
    url : 'https://curious-haddock-18941.upstash.io',
    token : 'AUn9AAIncDIwMjEwOWE5N2ZjMjM0YjQ1OWJjNDYyZGZmZGJhYzU5Y3AyMTg5NDE'
  });


  return redisInstance;
};

module.exports = { createRedisClient };


/*

import { createClient } from "redis"

const client = createClient({
  url: "rediss://default:AUn9AAIncDIwMjEwOWE5N2ZjMjM0YjQ1OWJjNDYyZGZmZGJhYzU5Y3AyMTg5NDE@curious-haddock-18941.upstash.io:6379"
});

client.on("error", function(err) {
  throw err;
});
await client.connect()
await client.set('foo','bar'); // key value

// Disconnect after usage
await client.disconnect();

*/