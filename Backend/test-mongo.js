const { MongoClient } = require('mongodb');

const uri = "mongodb://housepital:6xNQ02sD9EPIgKIV@ac-uwt42j4-shard-00-00.kj5vfon.mongodb.net:27017/Graduation?ssl=true&authSource=admin&directConnection=true";

const client = new MongoClient(uri, {
  serverSelectionTimeoutMS: 5000,
  connectTimeoutMS: 5000
});

async function run() {
  try {
    console.log("Connecting...");
    await client.connect();
    console.log("Connected successfully to server");
    const result = await client.db("admin").command({ hello: 1 });
    console.log("Replica Set Name:", result.setName);
    console.log("Me:", result.me);
    console.log("Hosts:", result.hosts);
  } catch (err) {
    console.error("Connection failed:", err.message);
    if (err.cause) console.error("Cause:", err.cause);
  } finally {
    await client.close();
  }
}

run();
