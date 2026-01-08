# Java Lambda Terraform Project

## Architecture Overview
This is a Java-based AWS Lambda function with Terraform infrastructure. The project uses a **modular Terraform structure** where reusable Lambda infrastructure lives in `module/lambda/` and environment-specific deployments are in `infra/lambda/`.

**Key Pattern**: The Terraform module (`module/lambda/`) is incomplete - it references `var.function_name` and `var.jar_path` without declaring them in `variables.tf`. These variables are **passed directly from the calling module** in `infra/lambda/main.tf`.

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

### CI/CD Pipeline
The project uses GitHub Actions (`.github/workflows/deploy-lambda.yml`) which:
1. Builds Java Lambda with Maven
2. Runs Terraform from `infra/lambda/`
3. Auto-applies on push to `main`

Required secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

## Terraform Patterns

### Module Usage Pattern
The `module/lambda/` module is intentionally minimal - it doesn't declare all variables it uses:
- `function_name` and `jar_path` are passed from caller but NOT in module's `variables.tf`
- Unused variables (`region`, `envname`, `bucket`) ARE declared but never referenced

**When modifying**: Add new Lambda variables directly to `infra/lambda/main.tf` module block, not necessarily to `module/lambda/variables.tf`.

### State Management
- **Backend**: S3 remote state (`s3-backend-remote1`) configured in `backend.tf`
- **Critical**: Backend region MUST match bucket region (currently `us-east-1`)

## Java Lambda Specifics

### Handler Configuration Mismatch
**Known Issue**: The handler in `module/lambda/main.tf` is:
```terraform
handler = "com.example.Handler::handleRequest"
```
But the actual Java class is `com.example.HelloHandler`, not `Handler`. This will cause deployment failures.

### Dependencies
Uses AWS Lambda Java Core SDK v1.2.2 with Maven Shade plugin for fat JAR packaging.

### Runtime
Java 17 (`java17` runtime in Terraform, Java 17 in GitHub Actions)

## When Adding New Lambda Functions
1. Create new directory under `app/`
2. Add Maven module with `maven-shade-plugin`
3. Create new root module under `infra/` (copy `infra/lambda/` as template)
4. Update JAR path and function name in the new infra module's `main.tf`
5. Consider fixing the handler class name mismatch pattern
