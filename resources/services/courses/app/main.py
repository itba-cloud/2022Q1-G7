# reference: https://fastapi.tiangolo.com/deployment/docker/
from typing import Union

from fastapi import APIRouter, FastAPI
from pydantic import BaseModel

app = FastAPI()

prefix_router = APIRouter(prefix="/courses")


class Course(BaseModel):
    id: str
    name: str
    teachers: list
    cover_image: str


@app.get("/health-check")
def health_check():
    return {"status": "ok"}


@prefix_router.get("/{course_id}",)
async def get_course(course_id: str):
    mock_course = Course(
        id=course_id,
        name="Python",
        teachers=["John", "Jane"],
        cover_image="https://www.python.org/static/img/python-logo.png"
    )
    return mock_course


app.include_router(prefix_router)
