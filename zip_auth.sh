cd resources/lambda/
pip install --target ./package boto3 PyJWT
cd package
zip -r ../auth_handler.zip .
cd ..
zip -g auth_handler.zip auth_handler.py
rm -rf package