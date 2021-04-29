const log = require('/opt/helpers/logger').logger;

const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient({ convertEmptyValues: true });

exports.lambdaHandler = async (event, context) => {
	try {
		log.info('Checking event');
		if (!event) throw new Error('Event not found');

		if (event.httpMethod !== 'GET') {
			log.info("Not Get Method")
			throw new Error(`get only accept GET method, you tried: ${event.httpMethod}`);
		}

		const params = {
			TableName : process.env.SongsTable,
			Key: event
		};

		log.info('Querying Dynamo DB');
		const data = await docClient.get(params).promise();
		const items = data.Item;
	
		const response = {
			status: 'Success',
			statusCode: 200,
			data: JSON.stringify(items)
		};
	
		log.info(`response from: ${event.path} statusCode: ${response.statusCode} body: ${response.body}`);
		return response;
		
	} catch (error) {
		console.log(error);
		log.error(error.message ? error.message : error);
		return { status: 'Error', message: error.message ? error.message : error };
	}
};