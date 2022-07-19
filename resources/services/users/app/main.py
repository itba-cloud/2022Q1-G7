# reference: https://fastapi.tiangolo.com/deployment/docker/
import base64
import enum
from urllib import response
import httpx
import jwt
from typing import Union
import os

from fastapi import APIRouter, FastAPI, Response, status

import boto3
from pydantic import BaseModel


class Role(enum.Enum):
    STUDENT = "student"
    TEACHER = "teacher"


class User(BaseModel):
    id: str
    email: str
    full_name: str
    role: Role


app = FastAPI()

dyanamodb = boto3.resource('dynamodb', region_name='us-east-1')
users = dyanamodb.Table('users')

prefix_router = APIRouter(prefix="/users")


client_id = os.getenv("CLIENT_ID", "bast2atl9hm3lopc88ie04k1")
client_secret = os.getenv(
    "CLIENT_SECRET", "u42sa6p705lctec8cr44veduo0aipf19ljmigi0b6u5n1b956n")
AUTH_DOMAIN = os.getenv(
    "AUTH_DOMAIN", "https://final-cloud-g7-auth-domain.auth.us-east-1.amazoncognito.com")
redirect_uri = os.getenv(
    "REDIRECT_URI", "https://www.final-cloud-g7-web.aleph51.com.ar.s3-website-us-east-1.amazonaws.com/cognito/callback")

PRIVATE_KEY = os.getenv("PRIVATE_KEY","private_key")
PUBLIC_KEY = os.getenv("PUBLIC_KEY",)

cognito_endpoint = f"{AUTH_DOMAIN}/oauth2/token"


@prefix_router.get("/login")
def login(code: str, response: Response):

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
        response.status_code = status.HTTP_418_IM_A_TEAPOT
        return oauth.json()

    headers = {
        'Authorization': f"Bearer {oauth.json()['access_token']}",
    }

    try:
        user = httpx.get(f"{AUTH_DOMAIN}/oauth2/userInfo", headers=headers)
    except Exception as e:
        print(e)
        response.status_code = status.HTTP_418_IM_A_TEAPOT
        return user.json()
    
    if user.status_code != 200:
        response.status_code = status.HTTP_418_IM_A_TEAPOT
        return user.json()
    

    item = {
        'id': user.json()['sub'],
        'email': user.json()['email'],
        'username': user.json()['username'],
        "id_token": oauth.json()['id_token'],
        "access_token": oauth.json()['access_token'],
        "refresh_token": oauth.json()['refresh_token'],
        "expires_in": oauth.json()['expires_in'],

    }

    jwt_payload = {
        "role": "student",
        "id": user.json()['sub'],
    }

    users.put_item(Item=item)

    jwt_token = jwt.encode(jwt_payload, PRIVATE_KEY, algorithm="HS256")

    payload = {
        "jwt": jwt_token,
    }
    return payload


@app.get("/health-check")
def health_check():
    return {"status": "ok"}


@prefix_router.get("/{user_id}")
async def get_user(user_id: str):

    mock_user = User(
        id=user_id,
        email="mock@email.com",
        full_name="Mock User",
        role=Role.STUDENT
    )

    return mock_user


app.include_router(prefix_router)
