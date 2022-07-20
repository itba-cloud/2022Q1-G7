const AWS = require('aws-sdk')
const ddb = new AWS.DynamoDB.DocumentClient()
exports.handler = async function(event, context) {
    try {
        await ddb
        .put({
            TableName: "dynamo-chat",
            Item: {
                connectionId: event.requestContext.connectionId,
            },
        })
        .promise()
    } catch(err) {
        return {
            statusCode: 500,
        }
    }
    return {
        statusCode: 200,
    }
}
