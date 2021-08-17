REGION="us-west-2"
ACCOUNT_NUMBER="097041003708"
VERSION_NUMBER="0.1"
REPO_NAME="nexus-container-repo"

docker build -t nexus-container .
docker tag nexus-container "$ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com/${REPO_NAME}:latest
docker tag nexus-container "$ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com/${REPO_NAME}:${VERSION_NUMBER}


aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com
docker push "$ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com/${REPO_NAME}:latest
docker push "$ACCOUNT_NUMBER".dkr.ecr."$REGION".amazonaws.com/${REPO_NAME}:${VERSION_NUMBER}

#terraform apply -var="image_full=$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/${REPO_NAME}:${VERSION_NUMBER}" -auto-approve