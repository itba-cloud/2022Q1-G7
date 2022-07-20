# reference: https://fastapi.tiangolo.com/deployment/docker/
import base64
import enum
import httpx
import jwt
from typing import Union
import os

from fastapi import APIRouter, Body, FastAPI, HTTPException, Response, status

import boto3
from pydantic import BaseModel


class Role(enum.Enum):
    STUDENT = "STUDENT"
    TEACHER = "TEACHER"
    NONE = "NONE"


class User(BaseModel):
    id: str
    email: str
    full_name: str
    role: Role


app = FastAPI()


prefix_router = APIRouter(prefix="/users")


client_id = os.getenv("CLIENT_ID", "bast2atl9hm3lopc88ie04k1")
client_secret = os.getenv(
    "CLIENT_SECRET", "u42sa6p705lctec8cr44veduo0aipf19ljmigi0b6u5n1b956n")
AUTH_DOMAIN = os.getenv(
    "AUTH_DOMAIN", "https://final-cloud-g7-auth-domain.auth.us-east-1.amazoncognito.com")
redirect_uri = os.getenv(
    "REDIRECT_URI", "http://localhost:3000/cognito/callback")

PRIVATE_KEY = os.getenv("PRIVATE_KEY", "private_key")
PUBLIC_KEY = os.getenv("PUBLIC_KEY",)

cognito_endpoint = f"{AUTH_DOMAIN}/oauth2/token"

dyanamodb = boto3.resource('dynamodb', region_name='us-east-1')
users = dyanamodb.Table('users')


def create_user(user, oauth):

    item = {
        'id': user.json()['sub'],
        'email': user.json()['email'],
        'username': user.json()['username'],
        "id_token": oauth.json()['id_token'],
        "access_token": oauth.json()['access_token'],
        "refresh_token": oauth.json()['refresh_token'],
        "expires_in": oauth.json()['expires_in'],
        "avatar_url": "",
        "role": Role.NONE.value

    }
    users.put_item(Item=item)
    return item


def update_user_auth(user, oauth):
    users.update_item(Key={'id': user.json()['sub']}, AttributeUpdates={
        'id_token': {'Value': oauth.json()['id_token']},
        'access_token': {'Value': oauth.json()['access_token']},
        'refresh_token': {'Value': oauth.json()['refresh_token']},
        'expires_in': {'Value': oauth.json()['expires_in']},
    })


@prefix_router.get("/login")
def login(code: str):

    msg_bytes = f"{client_id}:{client_secret}".encode('utf-8')
    msg_b64 = base64.b64encode(msg_bytes).decode('utf-8')

    headers = {
        'Authorization': f"Basic {msg_b64}",
        'Content-Type': 'application/x-www-form-urlencoded'
    }

    data = {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirect_uri
    }
    try:
        oauth = httpx.post(cognito_endpoint, headers=headers, data=data)
    except Exception as e:
        print(e)
        return {"error": "request to cognito failed"}

    if oauth.status_code != 200:
        raise HTTPException(status_code=oauth.status_code, detail=oauth.json())

    headers = {
        'Authorization': f"Bearer {oauth.json()['access_token']}",
    }

    try:
        user = httpx.get(f"{AUTH_DOMAIN}/oauth2/userInfo", headers=headers)
    except Exception as e:
        print(e)
        raise HTTPException(status_code=user.status_code, detail={
                            "message": "oath userinfo failed", "oauth": user.json()})

    if user.status_code != 200:
        raise HTTPException(status_code=user.status_code, detail=user.json())

    try:
        # get to dynamo
        user_db = users.get_item(Key={'id': user.json()['sub']})
    except Exception as e:
        print(e)
        raise HTTPException(status_code=user_db.status_code, detail=user_db.json())

    if not "Item" in user_db:
        user_db = create_user(user, oauth)

    else:
        update_user_auth(user, oauth)
        user_db = user_db['Item']

    jwt_payload = {
        "role": user_db['role'],
        "id": user.json()['sub'],
    }

    jwt_token = jwt.encode(jwt_payload, PRIVATE_KEY, algorithm="HS256")

    print(user_db)

    payload = {
        "user": {
            "id": user_db['id'],
            "email": user_db['email'],
            "name": user_db['username'],
            "role": user_db["role"],
            "avatarUrl": user_db["avatar_url"]
        },
        "token": jwt_token,
    }
    return payload


class UserUpdate(BaseModel):
    role: Role


@prefix_router.put("/{id}/role")
def update_role(id: str, user_update: UserUpdate):
    users.update_item(Key={'id': id}, AttributeUpdates={
        'role': {'Value': user_update.role.value}
    })
    return {"role": user_update.role.value}


@app.get("/health-check")
def health_check():
    return {"status": "ok"}


@prefix_router.get("/{user_id}")
async def get_user(user_id: str):

    user = users.get_item(Key={'id': user_id})

    if not "Item" in user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "id": user['Item']['id'],
        "email": user['Item']['email'],
        "name": user['Item']['username'],
        "role": user['Item']['role'],
        "avatarUrl": user['Item']['avatar_url']
    }


app.include_router(prefix_router)
