APP_NAME=gobid
REGION=us-east-1
VPC_ID=vpc-0746fa24ca42014c3
ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text)

SG_NAME=$(APP_NAME)
ECL_URL=$(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com
REPO_URL=$(ECL_URL)/$(APP_NAME)

create-sg:
@if ! aws ec2 describe-security-groups --filter "Name=group-name, Values=$(SG_NAME)" --regio $(REGION) -- QUERY "SecurityGroups[*].GroupId" --output text | grep -qE 'sg-'; then \
	echo "Creating security group $(SG_NAME)..."; \
	aws ec2 create-security-group \
		--group-name $(SG_NAME)
		--description "Allow Postgres for Gobid" \
		--vpc_id $(VPC_ID) \
		--region $(REGION); \
	else \
		echo "Security group $(SG_NAME) already exists."; \
	fi;
	SG_ID=$$(aws ec2 describe-security-groups --filter "Name=group-name, Values=$(SG_NAME)" --regio $(REGION) -- QUERY "SecurityGroups[*].GroupId" --output text); \
	echo "Authorizin port 5432 on SG $$SG_ID..."; \
	aws ec2 authorize-security-group-ingress \
		--group-id $$SG_ID \
		--protocol tcp \
		--port 5432 \
		--cidr 0.0.0.0/0 \
		--region $(REGION); || echo "Ingress rule already exists or failed silently."

create-ecr:
	aws ecr describe-repositories --repository-name $(APP_NAME) --region $(REGION) || \
	aws ecr create-repository --repository-name $(APP_NAME) --REGIO $(REGION)

build:
	docker build -t $(APP_NAME) -f Dockerfile.prod

tag:
	docker tag $(APP_NAME):latest $(REPO_URL):latest

push: tag
	aws ecr get-login-password --region $(REGION) | \
	docker login --username AWS --password-stdin $(ECL_URL)
	docker push $(REPO_URL):latest
