import jwt
import boto3
import os

PRIVATE_KEY = os.getenv("PRIVATE_KEY", "private_key")

dyanamodb = boto3.resource('dynamodb', region_name='us-east-1')
users = dyanamodb.Table('users')


def main(event, context):
    token = event['authorizationToken']
    try:
        payload = jwt.decode(token, PRIVATE_KEY, algorithm="HS256")
        user = users.get_item(Key={'id': payload['sub']})
        if 'Item' in user:
            return {
                'isAuthenticated': True,
                'user': user['Item']
            }
        else:
            return {
                'isAuthenticated': False
            }
    except jwt.ExpiredSignatureError:
        return {
            'isAuthenticated': False
        }
    except jwt.InvalidTokenError:
        return {
            'isAuthenticated': False
        }
    except Exception as e:
        print(e)
        return {
            'isAuthenticated': False
        }
