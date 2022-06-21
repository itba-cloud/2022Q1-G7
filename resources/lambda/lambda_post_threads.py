def main (event, context):
	print ("In lambda handler")

	resp = {
		"statusCode": 200,
		"headers": {
			"Access-Control-Allow-Origin": "*",
		},
		"body": "create threads"
	}

	return resp