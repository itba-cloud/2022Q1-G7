# reference: https://fastapi.tiangolo.com/deployment/docker/
from typing import Union

from fastapi import FastAPI

import httpx


app = FastAPI()


@app.get("/health-check")
def health_check():
    return {"status": "ok"}


@app.get("/forums")
def read_root():
    response = httpx.get("http://internal.service/users").json()
    return response["data"]
