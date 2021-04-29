const log = require('/opt/helpers/logger').logger;

var AWS = require('aws-sdk');
var docClient = new AWS.DynamoDB.DocumentClient({ convertEmptyValues: true });

exports.lambdaHandler = async (event, context) => {
	try {
		log.info('Checking event');
		if (!event) throw new Error('Event not found');

		if (event.httpMethod !== 'POST') {
			log.info("Not POST Method")
			throw new Error(`put only accept POST method, you tried: ${event.httpMethod}`);
		}

		const params = {
			TableName : process.env.SongsTable,
			Item: event,
		};
		
		log.info('Adding data to Dynamo DB');
		const response = await docClient.put(params).promise();
		log.info(response);

		return {
			status: 'Success',
			message: 'Data added successfully',
		};
		
	} catch (error) {
		log.error(error.message ? error.message : error);
		return { status: 'Error', message: error.message ? error.message : error };
	}
};