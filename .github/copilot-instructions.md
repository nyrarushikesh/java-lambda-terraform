# Java Lambda Terraform Project

## Architecture Overview
This is a Java-based AWS Lambda function with Terraform infrastructure and public Function URL access. The project uses a **modular Terraform structure** where reusable Lambda infrastructure lives in `module/lambda/` and environment-specific deployments are in `infra/lambda/`.

## Project Structure
```
app/hello-world/          # Java Lambda source & Maven build
infra/lambda/             # Terraform root module (environment-specific)
module/lambda/            # Reusable Terraform module
```

## Critical Developer Workflows

### Building the Lambda
```bash
cd app/hello-world
mvn clean package
```
Output JAR: `app/hello-world/target/hello-lambda-1.0.jar`

### Deploying with Terraform
```bash
cd infra/lambda
terraform init
terraform plan
terraform apply
```

**Important**: The JAR path in `infra/lambda/main.tf` uses a relative path (`../../app/hello-world/target/hello-lambda-1.0.jar`) from the infra directory.

### Getting the Function URL
After deployment, get the public URL:
```bash
cd infra/lambda
terraform output function_url
```
Or via AWS CLI:
```bash
aws lambda get-function-url-config --function-name hello-java --query 'FunctionUrl' --output text
```

### CI/CD Pipeline
The project uses GitHub Actions (`.github/workflows/deploy-lambda.yml`) which:
1. Builds Java Lambda with Maven
2. Runs Terraform from `infra/lambda/`
3. Recreates Function URL with correct permissions (AWS Oct 2025+ requirement)
4. Displays the Function URL in workflow logs
5. Auto-applies on push to `main`

Required secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

## Terraform Patterns

### Module Usage Pattern
The `module/lambda/` only declares variables that are actually used:
- `function_name` - Lambda function name
- `jar_path` - Path to compiled JAR file

Variables are passed from `infra/lambda/main.tf` to the module.

### State Management
- **Backend**: S3 remote state (`s3-backend-remote1`) configured in `backend.tf`
- **Region**: `us-east-1` (backend region must match bucket region)

## Java Lambda Specifics

### Handler Configuration
- **Class**: `com.example.HelloHandler`
- **Handler**: `com.example.HelloHandler::handleRequest`
- **Response Format**: Returns `Map<String, Object>` with `statusCode`, `body`, and `headers` for Function URL compatibility

### Function URL Response Format
Lambda Function URLs require structured responses:
```java
{
  "statusCode": 200,
  "body": "Hello World from Java Lambda!",
  "headers": {"Content-Type": "text/plain"}
}
```

### Dependencies
- AWS Lambda Java Core SDK v1.2.2
- Maven Shade plugin for fat JAR packaging
- Java 17 compiler configuration in pom.xml

### Runtime
Java 17 (`java17` runtime in Terraform, Java 17 in GitHub Actions)

## AWS Function URL Requirements (Oct 2025+)

**Critical**: Function URLs now require **both** permissions:
1. `lambda:InvokeFunctionUrl` - Allow Function URL invocation
2. `lambda:InvokeFunction` - Allow function execution

Both permissions are configured in `module/lambda/main.tf` and enforced in the GitHub Actions workflow.

## When Adding New Lambda Functions
1. Create new directory under `app/`
2. Add Maven module with `maven-shade-plugin` and Java 17 properties
3. Implement handler returning `Map<String, Object>` with statusCode/body/headers
4. Create new root module under `infra/` (copy `infra/lambda/` as template)
5. Update JAR path and function name in the new infra module's `main.tf`
6. Ensure both Function URL permissions are added for public access
