const { DynamoDBClient, DeleteItemCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({});

exports.handler = async (event) => {
  const params = {
    TableName: process.env.TABLE_NAME,
    Key: { id: { S: event.id } }
  };
  try {
    await client.send(new DeleteItemCommand(params));
    return {};
  } catch (err) {
    throw err;
  }
};