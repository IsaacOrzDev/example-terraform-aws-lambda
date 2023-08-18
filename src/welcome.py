import json
import random
import string
import random
import string
import re

def lambda_handler(event, context):

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'testing1'})
    }

def lambda_handler2(event, context):
    body = json.loads(event['body'])
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'testing2', 'name': body['name']})
    }
