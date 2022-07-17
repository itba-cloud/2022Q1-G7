# reference: https://fastapi.tiangolo.com/deployment/docker/
from typing import Union

from fastapi import FastAPI

import boto3

app = FastAPI()

dyanamodb = boto3.client('dynamodb')


@app.get("/health-check")
def health_check():
    return {"status": "ok"}


@app.get("/users")
def read_root():

    response = dyanamodb.get_item(TableName='users', Key={
                                  'user_id': {'S': '1234'}})

    return {
        "data": response['Item']['user_id']['S']
    }
