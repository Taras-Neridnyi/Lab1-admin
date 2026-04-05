const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({});

exports.handler = async (event) => {
  const Item = {
    id: { S: event.id },
    title: { S: event.title },
    watchHref: { S: event.watchHref },
    authorId: { S: event.authorId },
    length: { S: event.length },
    category: { S: event.category }
  };

  const params = {
    TableName: process.env.TABLE_NAME,
    Item: Item
  };

  try {
    await client.send(new PutItemCommand(params));
    return {
      id: Item.id.S,
      title: Item.title.S,
      watchHref: Item.watchHref.S,
      authorId: Item.authorId.S,
      length: Item.length.S,
      category: Item.category.S
    };
  } catch (err) {
    throw err;
  }
};