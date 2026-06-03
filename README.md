
serverless-image-processing-with-terraform
=================================================

Overview
--------

This project, `serverless-image-processing-with-terraform`, demonstrates a complete serverless image-processing pipeline deployed and managed using Terraform. It accepts images uploaded to an input S3 bucket, triggers a Lambda function to process the image (resize/convert/optimize), and writes the result to an output S3 bucket. The infrastructure is provisioned using Terraform modules and includes monitoring and notification components.

What the project does (step-by-step)
-----------------------------------

1. A client uploads an image to the input S3 bucket (an `incoming/` prefix).
2. S3 event notification triggers the Lambda function.
3. The Lambda function loads image-processing dependencies via a Lambda Layer (built with Docker for native libraries), processes the image (resize, optional format convert, optimization), and stores the processed image into the output S3 bucket.
4. Processing metadata and metrics are emitted to CloudWatch; alarms and notifications (SNS) are configured for failures or performance thresholds.
5. Terraform creates and manages all resources so the stack is reproducible and versionable.

AWS architecture (flow diagram)
-----------------------------

```mermaid
flowchart LR
	Client[Client / Uploader] -->|PUT image| S3In[S3 Input Bucket]
	S3In -->|S3 Event (PUT)| Lambda[Lambda Function]
	Lambda --> Layer[Lambda Layer\n(native libs)]
	Lambda -->|write| S3Out[S3 Output Bucket]
	Lambda -->|logs / metrics| CW[CloudWatch]
	CW -->|alarm| SNS[SNS Topic]
	SNS -->|notify| Ops[Operators / Email]
	Terraform[Terraform]
	Terraform -.-> S3In
	Terraform -.-> Lambda
	Terraform -.-> Layer
	Terraform -.-> S3Out
	Terraform -.-> CW
	Terraform -.-> SNS
```

Key features
------------

- Fully IaC: All infrastructure is defined and managed with Terraform modules.
- Native-image dependencies: Lambda Layer built inside Docker for correct native library binaries.
- Event-driven processing: S3 → Lambda pipeline with best-practice IAM scoping.
- Monitoring & alerts: CloudWatch metrics and alarms with SNS notifications.
- Reusable modules: Modules provided for Lambda, S3, CloudWatch, SNS, etc.

Project structure
-----------------

Top-level files and directories:

- lambda/
	- lambda_function.py — Lambda handler for image processing.
	- requirements.txt — Python deps for the Lambda function (packaged in layer as needed).
- scripts/
	- build_layer_docker.sh — Build the Lambda Layer with native image libs inside Docker.
	- deploy.sh — Convenience script to run Terraform deploy steps (project-specific).
	- destroy.sh — Convenience script to tear down the infrastructure.
- terraform/
	- main.tf — Root Terraform configuration to compose modules.
	- variables.tf, outputs.tf, provider.tf — standard Terraform artifacts.
	- modules/ — reusable modules for Lambda, S3, CloudWatch, SNS, etc.

How to test the project
-----------------------

Prerequisites:

- Install Terraform (compatible version as required by the project).
- Have AWS CLI configured with credentials and the target region.
- Docker installed for building the Lambda layer.

Basic flow to build and deploy locally (integration test):

1. Build the Lambda layer (creates artifacts with native libs):

```bash
./scripts/build_layer_docker.sh
```

2. Initialize and apply Terraform to create resources (you may customize `terraform/terraform.tfvars` first):

```bash
cd terraform
terraform init
terraform apply -var-file=terraform.tfvars
```

Alternatively use the project convenience script:

```bash
./scripts/deploy.sh
```

3. Upload a test image to the input S3 bucket (replace `<INPUT_BUCKET>` and `<KEY>` with your values):

```bash
aws s3 cp ./tests/sample.jpg s3://<INPUT_BUCKET>/incoming/sample.jpg
```

4. Verify the processed image appears in the output bucket (e.g., `processed/` prefix) and check CloudWatch logs for the Lambda invocation:

```bash
aws s3 ls s3://<OUTPUT_BUCKET>/processed/
aws logs tail /aws/lambda/<lambda-name> --since 1m
```

5. (Optional) Trigger a manual Lambda invocation for quick testing using a sample S3 event payload:

```bash
aws lambda invoke --function-name <lambda-name> --payload file://tests/sample-s3-event.json response.json
jq . response.json
```

6. To tear down the resources when finished:

```bash
cd terraform
terraform destroy -var-file=terraform.tfvars
```

Notes and tips
--------------

- Use `terraform.tfvars` under `terraform/` to set bucket names and other environment-specific inputs.
- Keep IAM permissions minimal when testing in real accounts.
- If processing native libraries fail on Lambda, rebuild the layer with the matching runtime and platform using `build_layer_docker.sh`.

Where to look in this repo
-------------------------

- Lambda code: `lambda/lambda_function.py`
- Layer build: `scripts/build_layer_docker.sh`
- Terraform root: `terraform/main.tf` and modules in `terraform/modules/`
