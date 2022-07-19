# reference: https://fastapi.tiangolo.com/deployment/docker/
import base64
import enum
import httpx
import string
from typing import Union
import os

from fastapi import APIRouter, FastAPI

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

dyanamodb = boto3.client('dynamodb', region_name='us-east-1')

prefix_router = APIRouter(prefix="/users")





#AUTH_DOMAIN = "https://final-cloud-g7-auth-domain.auth.us-east-1.amazoncognito.com"
#client_id = "4cjjqgfelmvbm1e5eafockn7v0"
#client_secret = "99djek255mchbnk8nk60s9470i9meud9a2mhgum2dqtt97tikhu"
#redirect_uri = "https://www.final-cloud-g7-web.aleph51.com.ar.s3-website-us-east-1.amazonaws.com/cognito/callback"

client_id = os.getenv("CLIENT_ID")
client_secret = os.getenv("CLIENT_SECRET")
AUTH_DOMAIN = os.getenv("AUTH_DOMAIN")
redirect_uri = os.getenv("REDIRECT_URI")

cognito_endpoint = f"{AUTH_DOMAIN}/oauth2/token"




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

    response = httpx.post(cognito_endpoint, headers=headers, data=data)

    #response = httpx.get(f"{AUTH_DOMAIN}/oauth2/userInfo", headers={'Authorization': f"Bearer {response.json()['access_token']}"})

    return response.json()

   

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
