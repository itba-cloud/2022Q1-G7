# reference: https://fastapi.tiangolo.com/deployment/docker/

import datetime
from uuid import uuid4
from fastapi import APIRouter, FastAPI, File, HTTPException, Form, Response, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import boto3
from boto3.dynamodb.conditions import Key, Attr

from typing import List, Union, Any

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


prefix_router = APIRouter(prefix="/courses")

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
courses = dynamodb.Table('courses')
users = dynamodb.Table('users')
s3_resource = boto3.resource('s3', region_name='us-east-1')
images = s3_resource.Bucket('final-cloud-g7-images')
content = s3_resource.Bucket('final-cloud-g7-content')
s3 = boto3.client('s3', region_name='us-east-1')


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
    content: Union[InputImage, None] = None
    file : str= Form(...)


@app.get("/health-check")
def health_check():
    return {"status": "ok"}


@prefix_router.get("", response_model=List[Course])
def get_courses(user_id: Union[str, None] = "#", role: Union[str, None] = "STUDENT"):
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

        KeyConditionExpression=((Key('PK').eq(f"user:{user_id}:STUDENT")
                                or Key('PK').eq(f"user:{user_id}:TEACHER"))
                                & Key('SK').eq(f"course:{course_id}"))
    )
    return len(sub['Items']) > 0


@ prefix_router.get("/{course_id}", response_model=CourseOverview)
async def get_course(course_id: str, user_id: Union[str, None] = "#"):
    item = courses.query(
        KeyConditionExpression=Key('PK').eq(f"course:{course_id}")
    )
    if len(item['Items']) == 0:
        raise HTTPException(status_code=404, detail="Course not found")
    item = item['Items'][0]

    course_overview = CourseOverview(
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
    item = courses.query(
        KeyConditionExpression=Key('PK').eq(f"course:{course_id}")
    )

    if len(item['Items']) == 0:
        raise HTTPException(status_code=404, detail="Course not found")
    item = item['Items'][0]

    if is_subscribed(user_id, course_id):
        raise HTTPException(status_code=409, detail="Already subscribed")

    courses.put_item(
        Item={
            'PK': f"user:{user_id}:STUDENT",
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
async def create_course(user_id:str = Form(...), image: UploadFile = File(...), name: str = Form(...), description: str = Form(...)):
    course_id = uuid4()

    #get owner info
    try:
        owner_info = users.get_item(Key={'id': user_id})['Item']
    except Exception as e:
        print(e)
        raise HTTPException(status_code=404, detail="User not found")

    #upload image
    if image:
        try:
            img = images.put_object(Bucket=images.name, Key= f"{course_id}-{image.filename}", Body=image.file)
        except:
            raise HTTPException(status_code=500, detail="Error uploading image")
    
    owner = {
        "id": user_id,
        "role": "teacher",
        "name": owner_info["username"],
        "avatarUrl": owner_info["avatar_url"],
        "email": owner_info["email"],
    }

    item_user = {
        'PK': f"user:{user_id}:TEACHER",
        'SK': f"course:{course_id}",
        'name': name,
        'description':description,
        'image': f"https://{images.name}.s3.amazonaws.com/{img.key}",
        'rating': -1,
        'owner': owner['name'],
    }

    courses.put_item(
        Item=item_user
    )

    item = {
        'PK': f"course:{course_id}",
        'SK': f"course:{course_id}",
        'name': name,
        'description': description,
        'image': f"https://{images.name}.s3.amazonaws.com/{img.key}",
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

    item['PK'] = f"user:#"
    courses.put_item(
        Item=item
    )
    return




@prefix_router.get("/{course_id}/content")
async def get_course_content(course_id: str, user_id: Union[str, None] = "#"):
    # search content in bucket folder course_id
    try:
        files = s3.list_objects_v2(Bucket=content.name, Prefix=course_id)
    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail={
                            "ex": str(e), "files": files})
    try:
        ret = [{
            "contentId": item["Key"].split("/")[-1],
            "content": {
                "name": item["Key"].split("/")[-1],
                "size": item["Size"],
            },
            "uploaded": item["LastModified"],
            "downloadUrl": ""
        } for item in files['Contents']]
    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail={
                            "ex": str(e), "files": files})
    return ret


@prefix_router.get("/{course_id}/content/{file_id}")
async def get_course_content_file(course_id: str, file_id: str):
    # search content in bucket folder course_id
    try:
        file = s3.get_object(Bucket=content.name, Key=f"{course_id}/{file_id}")
    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail={
                            "ex": str(e)})
    return Response(file['Body'].read(), media_type="application/octet-stream")



@prefix_router.post("/{course_id}/content", status_code=204)
#async def create_course_file(course_id: str , file: bytes = File(...)):
async def create_course_file(course_id: str , file: UploadFile = File(...)):
    # search content in bucket folder course_id
    try:
        s3.put_object(Bucket=content.name,
                      Key=f"{course_id}/{file.filename}", Body=file.file)
    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail={"ex": str(e)})
    return

@prefix_router.delete("/{course_id}/content/{file_id}", status_code=204)
async def delete_course_content_file(course_id: str, file_id: str):
    # search content in bucket folder course_id
    try:
        s3.delete_object(Bucket=content.name, Key=f"{course_id}/{file_id}")
    except Exception as e:
        print(e)
        raise HTTPException(status_code=500, detail={"ex": str(e)})
    return

app.include_router(prefix_router)
