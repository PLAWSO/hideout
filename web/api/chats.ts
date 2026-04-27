import type { VercelRequest, VercelResponse } from '@vercel/node'
const { MongoClient, ServerApiVersion } = require('mongodb');
const pageSize = 5;

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
		const page = parseInt(req.query.page as string) || 0;
		const result = await get(client, page);
		return res.status(200).json(result);
	}

	if (req.method == "POST"){
		const result = await save(client, req.body);
		if (!result) { return res.status(400).json({ error: "error saving chat" }) }
		return res.status(200).json(result);
	}
}

export async function get(client: typeof MongoClient, page: number) {
  const skip = page * pageSize;
	console.log(page)

  try {
    await client.connect();
    const chats = await client
      .db("hideout")
      .collection("chats")
      .find({})
      .sort({ enteredOn: -1 })
      .skip(skip)
      .limit(pageSize)
      .toArray();

    return chats;
  } finally {
		await client.close();
  }
}

async function save(client: typeof MongoClient, body: any) {
	const { username, url, message } = body ?? {}

	if (!username || !message) {
		return false;
	}

	const parsedUsername = username.substring(0, 20).trim();
	const parsedMessage = message.substring(0, 200).trim();
	const parsedUrl = url.substring(0, 40).trim();

	if (parsedUsername.length === 0 || parsedMessage.length === 0) {
		return false;
	}

  try {
    await client.connect();
    const db = client.db("hideout").collection("chats");
    await db.insertOne({
			username: parsedUsername,
			message: parsedMessage,
			url: parsedUrl,
			enteredOn: new Date()
		})
		
		console.log(`${parsedUsername} said ${parsedMessage} with url ${parsedUrl}`);

    const chats = await db
      .find({})
      .sort({ enteredOn: -1 })
      .limit(pageSize)
      .toArray();

    return chats;
  } finally {
		await client.close();
  }
}
