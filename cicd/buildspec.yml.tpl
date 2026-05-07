version: 0.2

phases:
  install:
    runtime-versions:
      java: 17

  pre_build:
    commands:
      - echo Logging in to ECR...
      - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URI
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - BUILD_TAG=$${COMMIT_HASH:-$IMAGE_TAG}

  build:
    commands:
      - echo Building Maven module ${service_module}...
      - ./mvnw clean package -pl ${service_module} -am -DskipTests -B
      - echo Building Docker image...
      - docker build -t $ECR_REPO_URI:$BUILD_TAG -t $ECR_REPO_URI:latest -f docker/Dockerfile --build-arg SERVICE_NAME=${service_module} .

  post_build:
    commands:
      - echo Pushing image to ECR...
      - docker push $ECR_REPO_URI:$BUILD_TAG
      - docker push $ECR_REPO_URI:latest
      - echo Updating EKS deployment...
      - aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME
      - kubectl set image deployment/${service_module} app=$ECR_REPO_URI:$BUILD_TAG --namespace=petclinic || true
      - echo Writing image definitions file...
      - printf '[{"name":"app","imageUri":"%s"}]' $ECR_REPO_URI:$BUILD_TAG > imagedefinitions.json

artifacts:
  files:
    - imagedefinitions.json

cache:
  paths:
    - '/root/.m2/**/*'
