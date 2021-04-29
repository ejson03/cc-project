const dynamodb = require('aws-sdk/clients/dynamodb');
const docClient = new dynamodb.DocumentClient();

const tableName = process.env.TABLE;

exports.writeHandler = async (event, context) =>{
    if (event.httpMethod !== 'POST') {
        throw new Error(`postMethod only accepts POST method, you tried: ${event.httpMethod} method.`);
    }
    let response;
    try {
        const body = JSON.parse(event.body)
        console.log("############", body)
        const params = {
            "TableName" : tableName,
            "Item": body
        };
        const result = await docClient.put(params).promise();

         response = {
            'statusCode': 200,
            'body': "test",
        };

        console.info(`response from: ${event.path} statusCode: ${response.statusCode} body: ${response.body}`);
    } catch (err) {
        console.log(err);
        return err;
    }
    return response;
}

