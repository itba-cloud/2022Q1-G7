import os
import sys


region = 'us-east-1'

account = "414974971712"


imagesMap = {
    "users": {
        'name': "ecr-users",
        'location': 'resources/services/users/',
        'service': "users-service"
    },
    "courses": {
        'name': "ecr-courses",
        'location': 'resources/services/courses/',
        'service': "courses-service"
    }
}

#select images
images = []
if len(sys.argv) > 1:
    for arg in sys.argv[1:]:
        if arg in imagesMap:
            images.append(imagesMap[arg])
else:
    images = imagesMap.values()

# login
os.system(
    f"aws ecr get-login-password --region  {region} | docker login --username AWS --password-stdin {account}.dkr.ecr.{region}.amazonaws.com")

for image in images:
    # build
    os.system(f"docker build -t {image['name']} {image['location']}")

    # tag
    os.system(
        f"docker tag {image['name']}:latest {account}.dkr.ecr.{region}.amazonaws.com/{image['name']}:latest")

answer = input("(y/n) to push and redeploy...")
if answer != "y":
    exit()
for image in images:
    # push
    os.system(
        f"docker push {account}.dkr.ecr.{region}.amazonaws.com/{image['name']}:latest")

    # redeploy

    os.system(
        f"aws ecs update-service --cluster final-cloud-g7-ecs-cluster --service {image['service']} --region {region} --force-new-deployment")
