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

	if (req.method == "GET"){
		const result = await get(client);
		return res.status(200).json(result);
	}

	if (req.method == "POST"){
		const result = await save(client, req.body);
		if (!result) { return res.status(400).json({ error: "invalid username or score, or maybe a network issue? who's to say really" }) }
		return res.status(200).json(result);
	}
}

export async function get(client: typeof MongoClient) {
  try {
    await client.connect();
    const percentiles = await client
      .db("hideout")
      .collection("runs")
      .aggregate([
				{
					$group: {
						_id: null,
						percentiles: {
							$percentile: {
								input: "$score",
								p: [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 0.96, 0.97, 0.98, 0.99],
								method: "approximate"
							}
						}
					}
				}
			])
			.toArray();
		
		const topRuns = await client
		.db("hideout")
		.collection("runs")
		.find({ })
		.sort({ score: -1 })
		.project({
			"_id": 0,
			"score": 1,
			"username": 1
		})
		.limit(10)
		.toArray();

    return { percentiles: percentiles?.[0]?.percentiles, topRuns };
  } finally {
		await client.close();
  }
}

async function save(client: typeof MongoClient, body: any) {
	const { username, score } = body ?? {}
	const parsedScore = Number(score)

	if (!username || Number.isNaN(parsedScore) || parsedScore <= 0) {
		return false;
	}

	let parsedUsername = username.substring(0, 20).trim();

  try {
    await client.connect();
    const runs = await client
      .db("hideout")
      .collection("runs")
      .insertOne({
				parsedUsername,
				score: parsedScore,
				completed: false,
				doneOn: new Date()
			})
		
		console.log(`saved run for ${parsedUsername} with score ${parsedScore}`);

    return runs;
  } finally {
		await client.close();
  }
}
