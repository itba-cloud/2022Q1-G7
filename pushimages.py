import os

region = 'us-east-1'

account = "414974971712"


images = [
    {
        'name': "ecr-users",
        'location': 'resources/services/users/',
        'service':"users-service"
    },
        {
        'name': "ecr-courses",
        'location': 'resources/services/courses/',
        'service':"courses-service"
    }
]

#login



os.system(f"aws ecr get-login-password --region  {region} | docker login --username AWS --password-stdin {account}.dkr.ecr.{region}.amazonaws.com")

for image in images:
    #build
    os.system(f"docker build -t {image['name']} {image['location']}")

    #tag
    os.system(f"docker tag {image['name']}:latest {account}.dkr.ecr.{region}.amazonaws.com/{image['name']}:latest")

    #push
    os.system(f"docker push {account}.dkr.ecr.{region}.amazonaws.com/{image['name']}:latest")

    #redeploy

    os.system(f"aws ecs update-service --cluster final-cloud-g7-ecs-cluster --service {image['service']} --region {region} --force-new-deployment")