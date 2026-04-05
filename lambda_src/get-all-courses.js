const { DynamoDBClient, ScanCommand } = require("@aws-sdk/client-dynamodb");
const client = new DynamoDBClient({});

exports.handler = async (event) => {
  const params = { TableName: process.env.TABLE_NAME };
  try {
    const data = await client.send(new ScanCommand(params));
    return (data.Items || []).map(item => ({
      id: item.id?.S,
      title: item.title?.S,
      watchHref: item.watchHref?.S,
      authorId: item.authorId?.S,
      length: item.length?.S,
      category: item.category?.S
    }));
  } catch (err) {
    throw err;
  }
};