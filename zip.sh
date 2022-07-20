cd resources/lambda
rm *.zip
find . -type f -execdir zip '{}.zip' '{}' \;
