module "lambda" {
  source = "../../module/lambda"

  bucket        = var.bucket
  region        = var.region
  function_name = "hello-java"
  jar_path      = "../../app/hello-world/target/hello-lambda-1.0.jar"
}
