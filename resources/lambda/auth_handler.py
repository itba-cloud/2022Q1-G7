import jwt
import boto3
import os

PRIVATE_KEY = os.getenv("PRIVATE_KEY", "private_key")

dyanamodb = boto3.resource('dynamodb', region_name='us-east-1')
users = dyanamodb.Table('users')


def main(event, context):
    print(event)
    # check if login
    if event['pathParameters']['proxy'] == 'users/login':
        return {
            'isAuthorized': True,
        }

    if ('headers' not in event) or ('authorization' not in event['headers']):
        print("No authorization header")
        return {
            'isAuthorized': False,
        }

    token = event['headers']['authorization'].split(' ')[1]
    print(token)
    try:
        print(PRIVATE_KEY)
        payload = jwt.decode(token, PRIVATE_KEY, algorithms="HS256")
        print(payload)
        user = users.get_item(Key={'id': payload['id']})
        print(user)
        if 'Item' in user:
            return {
                'isAuthorized': True,
                'user': user['Item']
            }
        else:
            return {
                'isAuthorized': False
            }
    except jwt.ExpiredSignatureError:
        print("Signature expired")
        return {
            'isAuthorized': False
        }
    except jwt.InvalidTokenError:
        print("Invalid token")
        return {
            'isAuthorized': False
        }
    except Exception as e:
        print(e)
        return {
            'isAuthorized': False
        }
