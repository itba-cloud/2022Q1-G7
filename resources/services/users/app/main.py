# reference: https://fastapi.tiangolo.com/deployment/docker/
import enum
import string
from typing import Union

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

dyanamodb = boto3.client('dynamodb')

prefix_router = APIRouter(prefix="/users")


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
