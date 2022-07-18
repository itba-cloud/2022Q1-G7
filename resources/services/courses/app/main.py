# reference: https://fastapi.tiangolo.com/deployment/docker/
from typing import Union

from fastapi import APIRouter, FastAPI
from pydantic import BaseModel
import boto3

app = FastAPI()

prefix_router = APIRouter(prefix="/courses")

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('courses')

class Course(BaseModel):
    id: str
    name: str
    teachers: list
    cover_image: str



@app.get("/health-check")
def health_check():
    return {"status": "ok"}


import json

@prefix_router.get("/{course_id}",)
async def get_course(course_id: str):
    return table.get_item(Key={'id': course_id})['Item']
    #return json.dumps(dynamodb.get_item(TableName='courses', Key={'id': {'S': course_id}}))


#@prefix_router.get("/recently-watched")

app.include_router(prefix_router)
