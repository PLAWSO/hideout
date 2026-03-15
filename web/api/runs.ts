import type { VercelRequest, VercelResponse } from '@vercel/node'
const { MongoClient, ServerApiVersion } = require('mongodb');

export default async function handler(req: VercelRequest, res: VercelResponse) {
	const uri = process.env.MONGODB_CONNECTION_STRING
	
	const client = new MongoClient(uri, {
		serverApi: {
			version: ServerApiVersion.v1,
			strict: true,
			deprecationErrors: true,
		}
	});

	if (req.query.type == "save"){
		let score = +req.query.score;
		if (isNaN(score)) return;

		try {
			const response = await save(client, score);
	
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
}

async function get(client: typeof MongoClient) {
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

async function save(client: typeof MongoClient, score: number) {
  try {
    await client.connect();
    const runs = await client
      .db("hideout")
      .collection("runs")
      .insertOne({
				username: "Test Player",
				score: score,
				completed: false,
				doneOn: new Date()
			})

    return runs;
  } finally {
		await client.close();
  }
}
