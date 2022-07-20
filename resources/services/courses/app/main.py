# reference: https://fastapi.tiangolo.com/deployment/docker/

import datetime
from uuid import uuid4
from fastapi import APIRouter, FastAPI, HTTPException
from pydantic import BaseModel
import boto3
from boto3.dynamodb.conditions import Key, Attr

from typing import List, Union, Any

app = FastAPI()

prefix_router = APIRouter(prefix="/courses")

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
courses = dynamodb.Table('courses')


class Course(BaseModel):
    id: str
    name: str
    description: str
    owner: str
    image: str
    rating: float


class CourseOverview(BaseModel):
    data: Union[Course, None] = None
    owner: Any
    numberOfStudents: int
    numberOfTeachers: int
    lastUpdated: str
    subscribed: bool


class InputImage(BaseModel):
    name: Union[str, None] = None
    base64: Union[str, None] = None
    type: Union[str, None] = None
    size: Union[float, None] = None


class InputCourse(BaseModel):
    name: str
    description: str
    image: Union[InputImage, None] = None


class InputCourseFile(BaseModel):
    id: str
    content: Union[InputImage, None] = None
    file: bytes


@app.get("/health-check")
def health_check():
    return {"status": "ok"}


@prefix_router.get("", response_model=List[Course])
def get_courses(user_id: Union[str, None] = "#", role: Union[str, None] = "student"):
    if user_id == "#":
        role = None
    role = f":{role}" if role else ""
    key = f"user:{user_id}" + role
    items = courses.query(KeyConditionExpression=Key('PK').eq(key))
    return [Course(
        id=item['SK'].split(":")[1],
        name=item['name'],
        description=item['description'],
        image=item['image'],
        rating=item['rating'],
        owner=item['owner'])
        for item in items['Items']]


def is_subscribed(user_id: str, course_id: str):
    sub = courses.query(

        KeyConditionExpression=((Key('PK').eq(f"user:{user_id}:student")
                                or Key('PK').eq(f"user:{user_id}:teacher"))
                                & Key('SK').eq(f"course:{course_id}"))
    )
    return len(sub['Items']) > 0


@ prefix_router.get("/{course_id}", response_model=CourseOverview)
async def get_course(course_id: str, user_id: Union[str, None]="#"):
    item=courses.query(
        KeyConditionExpression=Key('PK').eq(f"course:{course_id}")
    )
    if len(item['Items']) == 0:
        raise HTTPException(status_code=404, detail="Course not found")
    item=item['Items'][0]

    course_overview=CourseOverview(
        data=Course(id=item['SK'].split(":")[1], name=item['name'], description=item['description'],
                    image=item['image'], rating=item['rating'], owner=item['owner']),
        owner=item['owner_info'],
        numberOfStudents=item['students'],
        numberOfTeachers=item['teachers'],
        lastUpdated=item['lastUpdated'],
        subscribed=is_subscribed(user_id, course_id)
    )
    return course_overview


@ prefix_router.post("/subscriptions", status_code=201)
async def subscribe_to_course(course_id: str, user_id: str):
    item=courses.query(
        KeyConditionExpression=Key('PK').eq(f"course:{course_id}")
    )

    if len(item['Items']) == 0:
        raise HTTPException(status_code=404, detail="Course not found")
    item=item['Items'][0]

    if is_subscribed(user_id, course_id):
        raise HTTPException(status_code=409, detail="Already subscribed")

    courses.put_item(
        Item={
            'PK': f"user:{user_id}:student",
            'SK': f"course:{course_id}",
            'name': item['name'],
            'description': item['description'],
            'image': item['image'],
            'rating': item['rating'],
            'owner': item['owner'],
        }
    )

    item['students'] += 1
    courses.put_item(
        Item=item)


@ prefix_router.post("", status_code=201)
async def create_course(user_id: str, course: InputCourse):
    course_id=uuid4()
    owner={
        "id": user_id,
        "role": "teacher",
        "name": "Jhon Doe",
        "avatarUrl": "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50?s=200",
        "email": "jhondoe@mail.com",
    }

    item_user={
        'PK': f"user:{user_id}:student",
        'SK': f"course:{course_id}",
        'name': course.name,
        'description': course.description,
        'image': '',
        'rating': -1,
        'owner': owner['name'],
    }

    courses.put_item(
        Item=item_user
    )

    item={
        'PK': f"course:{course_id}",
        'SK': f"course:{course_id}",
        'name': course.name,
        'description': course.description,
        'image': '',
        'rating': -1,
        'owner': owner['name'],
        'owner_info': owner,
        'students': 0,
        'teachers': 1,
        'lastUpdated': str(datetime.datetime.now())
    }

    courses.put_item(
        Item=item
    )

    item['PK']=f"user:#"
    courses.put_item(
        Item=item
    )
    return


@ prefix_router.post("/courses/{course_id}/files", status_code=204)
async def create_course_file(course_id: str, file: InputCourseFile):
    raise HTTPException(status_code=501, detail="Not implemented")

app.include_router(prefix_router)
