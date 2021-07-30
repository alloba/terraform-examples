REGION="us-east-1"
ACCOUNT_NUMBER="963527945348"
VERSION_NUMBER="1.0"
REPO_NAME="terraform-example-fargate-public-ecr"

docker build -t example/hello-world .
docker tag example/hello-world "$ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com/${REPO_NAME}:latest
docker tag example/hello-world "$ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com/${REPO_NAME}:${VERSION_NUMBER}


aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com
docker push "$ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com/${REPO_NAME}:latest
docker push "$ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com/${REPO_NAME}:${VERSION_NUMBER}

#terraform apply -var="image_full=$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/${REPO_NAME}:${VERSION_NUMBER}" -auto-approve