import type { VercelRequest, VercelResponse } from '@vercel/node'
const { MongoClient, ServerApiVersion } = require('mongodb');

async function run(client: typeof MongoClient) {
  try {
    await client.connect();
    const runs = await client
      .db("hideout")
      .collection("runs")
      .find({})
      .toArray();

    return runs;
  } finally {
		await client.close();
  }
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
	const uri = process.env.MONGODB_CONNECTION_STRING
	
	const client = new MongoClient(uri, {
		serverApi: {
			version: ServerApiVersion.v1,
			strict: true,
			deprecationErrors: true,
		}
	});

	if (req.query.type == "getTop100"){
		console.log("GETTING TOP 100")
	}

	try {
		const response = await run(client);

		return res.status(200).json({
			response,
		});
	} catch (err) {
		console.error("[" + new Date() + "] ERROR:\n", err);
		return res.status(500).json({
			message: "Failed to read data from MongoDB"
		});
	}
}
