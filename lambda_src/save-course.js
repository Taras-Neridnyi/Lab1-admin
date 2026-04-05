const { DynamoDBClient, PutItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({});

const replaceAll = (str, find, replace) => {
  return str.replace(new RegExp(find, "g"), replace);
};

exports.handler = async (event) => {
  const id = replaceAll(event.title, " ", "-").toLowerCase();
  const Item = {
    id: { S: id },
    title: { S: event.title },
    watchHref: { S: `http://www.pluralsight.com/courses/${id}` },
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