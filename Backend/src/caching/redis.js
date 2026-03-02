const { Redis } = require('@upstash/redis');

let redisInstance = null;

/**
 * Creates a fault-tolerant Redis client.
 * Every operation is wrapped in try/catch — if Redis is unreachable
 * the server keeps running and all cache ops silently return null.
 */
const createRedisClient = () => {
  if (redisInstance) return redisInstance;

  const url   = process.env.UPSTASH_REDIS_REST_URL   || 'https://curious-haddock-18941.upstash.io';
  const token = process.env.UPSTASH_REDIS_REST_TOKEN || 'AUn9AAIncDIwMjEwOWE5N2ZjMjM0YjQ1OWJjNDYyZGZmZGJhYzU5Y3AyMTg5NDE';

  let rawClient;
  try {
    rawClient = new Redis({ url, token });
  } catch (err) {
    console.warn('⚠️  Redis: failed to create client —', err.message);
    rawClient = null;
  }

  // Proxy that catches every async failure so the server never crashes
  redisInstance = new Proxy(
    {},
    {
      get(_, prop) {
        return async (...args) => {
          if (!rawClient) return null;
          try {
            return await rawClient[prop](...args);
          } catch (err) {
            console.warn(`⚠️  Redis.${prop}() failed (cache miss) — ${err.message}`);
            return null;
          }
        };
      },
    }
  );

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