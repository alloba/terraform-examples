docker build -t example/hello-world
docker tag example/hello-world $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/testing-ecr-repo:latest

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com
docker push $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/testing-ecr-repo:latest
docker push $ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/testing-ecr-repo:${VERSION_NUMBER}

terraform apply -var="image-full=$ACCOUNT_NUMBER.dkr.ecr.$REGION.amazonaws.com/testing-ecr-repo:${VERSION_NUMBER}" -auto-approve