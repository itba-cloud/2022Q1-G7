import boto3
import json
from decimal import Decimal


dyanamodb = boto3.client('dynamodb', region_name='us-east-1')
courses = [
    {
        "PK": 'user:#',
        "SK": 'course:1',
        "name": 'Introduction to Computer Science',
        "description":
        'This course is designed to give students a basic understanding of the fundamental concepts of computer science.',
        "owner": 'Dr. John Smith',
        "image": 'https://images.unsplash.com/photo-1452457750107-cd084dce177d?ixlib=rb-1.2.1&ix"id"=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y29tcHV0ZXIlMjBzY2llbmR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        "rating": 4.3,
    },
    {
        "PK": 'user:#',
        "SK": 'course:2',
        "name": 'Machine Learning',
        "description":
        'This course is designed to give students a basic understanding of the fundamental concepts of machine learning.',
        "owner": 'Dr. John Smith',
        "image": 'https://images.unsplash.com/photo-1445620466293-d6316372ab59?ixlib=rb-1.2.1&ix"id"=MnwxMjA3fDB8MHxzZWFyY2h8NXx8Y29tcHV0ZXIlMjBzY2llbmR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        "rating": 4.3,
    },
    {
        "PK": 'user:1:student',
        "SK": 'course:1',
        "name": 'Introduction to Computer Science',
        "description":
        'This course is designed to give students a basic understanding of the fundamental concepts of computer science.',
        "owner": 'Dr. John Smith',
        "image": 'https://images.unsplash.com/photo-1452457750107-cd084dce177d?ixlib=rb-1.2.1&ix"id"=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y29tcHV0ZXIlMjBzY2llbmR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        "rating": 4.3,
    },
    {
        "PK": 'user:1:student',
        "SK": 'course:2',
        "name": 'Machine Learning',
        "description":
        'This course is designed to give students a basic understanding of the fundamental concepts of machine learning.',
        "owner": 'Dr. John Smith',
        "image": 'https://images.unsplash.com/photo-1445620466293-d6316372ab59?ixlib=rb-1.2.1&ix"id"=MnwxMjA3fDB8MHxzZWFyY2h8NXx8Y29tcHV0ZXIlMjBzY2llbmR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        "rating": 4.3,
    },
    {
        "PK": 'user:1:student',
        "SK": 'course:2',
        "name": 'Machine Learning',
        "description":
        'This course is designed to give students a basic understanding of the fundamental concepts of machine learning.',
        "owner": 'Dr. John Smith',
        "image": 'https://images.unsplash.com/photo-1445620466293-d6316372ab59?ixlib=rb-1.2.1&ix"id"=MnwxMjA3fDB8MHxzZWFyY2h8NXx8Y29tcHV0ZXIlMjBzY2llbmR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        "rating": 4.3,
    },
    {
        "PK": 'course:1',
        "SK": 'course:1',
        "name": 'Introduction to Computer Science',
        "description":
        'This course is designed to give students a basic understanding of the fundamental concepts of computer science.',
        "owner": 'Dr. John Smith',
        "owner_info": {
            "id": '100',
            "name": 'Dr. John Smith',
            "email": 'drsmith@mail.com',
            'avatarUrl': 'https://images.unsplash.com/photo-1452457750107-cd084dce177d?ixlib=rb-1.2.1&ix"id"=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y29tcHV0ZXIlMjBzY2llbmR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
            "role": 'teacher'
        },
        "image": 'https://images.unsplash.com/photo-1452457750107-cd084dce177d?ixlib=rb-1.2.1&ix"id"=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y29tcHV0ZXIlMjBzY2llbmR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        "rating": 4.3,
        "students": 10,
        "teachers": 5,
        "lastUpdated": '2019-01-01T00:00:00.000Z',
    },
    {
        "PK": 'course:2',
        "SK": 'course:2',
        "name": 'Machine Learning',
        "description":
        'This course is designed to give students a basic understanding of the fundamental concepts of machine learning.',
        "owner": 'Dr. John Smith',
        "owner_info": {
            "id": '100',
            "name": 'Dr. John Smith',
            "email": 'drsmith@mail.com',
            'avatarUrl': 'https://images.unsplash.com/photo-1452457750107-cd084dce177d?ixlib=rb-1.2.1&ix"id"=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y29tcHV0ZXIlMjBzY2llbmR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
            "role": 'teacher'
        },
        "image": 'https://images.unsplash.com/photo-1445620466293-d6316372ab59?ixlib=rb-1.2.1&ix"id"=MnwxMjA3fDB8MHxzZWFyY2h8NXx8Y29tcHV0ZXIlMjBzY2llbmR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60',
        "rating": 4.3,
        "students": 15,
        "teachers": 1,
        "lastUpdated": '2019-01-01T00:00:00.000Z',
    }, ]


dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('courses')

for course in courses:
    #dyanamodb.put_item(TableName='courses', Item=course)
    item = json.loads(json.dumps(course), parse_float=Decimal)
    table.put_item(Item=item)
