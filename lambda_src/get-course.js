const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({});

exports.handler = async (event) => {
  const params = {
    TableName: process.env.TABLE_NAME,
    Key: { id: { S: event.id } }
  };
  try {
    const data = await client.send(new GetItemCommand(params));
    if (!data.Item) return {};
    return {
      id: data.Item.id?.S,
      title: data.Item.title?.S,
      watchHref: data.Item.watchHref?.S,
      authorId: data.Item.authorId?.S,
      length: data.Item.length?.S,
      category: data.Item.category?.S
    };
  } catch (err) {
    throw err;
  }
};