#reference: https://fastapi.tiangolo.com/deployment/docker/
from typing import Union

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return "forums info"

