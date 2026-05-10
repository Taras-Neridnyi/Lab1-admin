# ==============================================================================
# 1. СТВОРЕННЯ API ТА РЕСУРСІВ
# ==============================================================================
module "api_label" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  namespace = "uni"
  stage     = "dev"
  name      = "courses-api"
}

resource "aws_api_gateway_rest_api" "api" {
  name        = module.api_label.id
  description = "API for Serverless Courses Application"
}

# Ресурс /authors
resource "aws_api_gateway_resource" "authors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "authors"
}

# Ресурс /courses
resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "courses"
}

# Ресурс /courses/{id}
resource "aws_api_gateway_resource" "course_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.courses.id
  path_part   = "{id}"
}

# ==============================================================================
# 2. МОДЕЛІ ТА ВАЛІДАЦІЯ
# ==============================================================================
resource "aws_api_gateway_model" "course_model" {
  rest_api_id  = aws_api_gateway_rest_api.api.id
  name         = "CourseInputModel"
  content_type = "application/json"
  schema = jsonencode({
    "$schema"  = "http://json-schema.org/schema#"
    "title"    = "Course InputModel"
    "type"     = "object"
    "properties" = {
      "title"    = { "type" = "string" }
      "authorId" = { "type" = "string" }
      "length"   = { "type" = "string" }
      "category" = { "type" = "string" }
    }
    "required" = ["title", "authorId", "length", "category"]
  })
}

resource "aws_api_gateway_request_validator" "validator" {
  name                  = "ValidateBody"
  rest_api_id           = aws_api_gateway_rest_api.api.id
  validate_request_body = true
}

# ==============================================================================
# 3. МЕТОДИ ДЛЯ /authors
# ==============================================================================
# GET /authors
resource "aws_api_gateway_method" "get_authors" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.authors.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "get_authors_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.authors.id
  http_method             = aws_api_gateway_method.get_authors.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.get_all_authors.invoke_arn
}
resource "aws_api_gateway_method_response" "get_authors_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.get_authors.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration_response" "get_authors_res" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.get_authors.http_method
  status_code = aws_api_gateway_method_response.get_authors_200.status_code
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on = [aws_api_gateway_integration.get_authors_int]
}

# ==============================================================================
# 4. МЕТОДИ ДЛЯ /courses
# ==============================================================================
# GET /courses
resource "aws_api_gateway_method" "get_courses" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "get_courses_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.get_courses.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.get_all_courses.invoke_arn
}
resource "aws_api_gateway_method_response" "get_courses_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.get_courses.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration_response" "get_courses_res" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.get_courses.http_method
  status_code = aws_api_gateway_method_response.get_courses_200.status_code
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on = [aws_api_gateway_integration.get_courses_int]
}

# POST /courses
resource "aws_api_gateway_method" "post_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "POST"
  authorization = "NONE"
  request_validator_id = aws_api_gateway_request_validator.validator.id
  request_models = {
    "application/json" = aws_api_gateway_model.course_model.name
  }
}
resource "aws_api_gateway_integration" "post_course_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.post_course.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.save_course.invoke_arn
}
resource "aws_api_gateway_method_response" "post_course_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.post_course.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration_response" "post_course_res" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.post_course.http_method
  status_code = aws_api_gateway_method_response.post_course_200.status_code
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on = [aws_api_gateway_integration.post_course_int]
}

# ==============================================================================
# 5. МЕТОДИ ДЛЯ /courses/{id}
# ==============================================================================
# GET /courses/{id}
resource "aws_api_gateway_method" "get_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = { "method.request.path.id" = true }
}
resource "aws_api_gateway_integration" "get_course_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.get_course.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.get_course.invoke_arn
  request_templates = {
    "application/json" = <<EOF
{
  "id": "$input.params('id')"
}
EOF
  }
}
resource "aws_api_gateway_method_response" "get_course_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.get_course.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration_response" "get_course_res" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.get_course.http_method
  status_code = aws_api_gateway_method_response.get_course_200.status_code
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on = [aws_api_gateway_integration.get_course_int]
}

# PUT /courses/{id}
resource "aws_api_gateway_method" "put_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "PUT"
  authorization = "NONE"
  request_parameters = { "method.request.path.id" = true }
}
resource "aws_api_gateway_integration" "put_course_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.put_course.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.update_course.invoke_arn
  request_templates = {
    "application/json" = <<EOF
{
  "id": "$input.params('id')",
  "title": $input.json('$.title'),
  "authorId": $input.json('$.authorId'),
  "length": $input.json('$.length'),
  "category": $input.json('$.category'),
  "watchHref": $input.json('$.watchHref')
}
EOF
  }
}
resource "aws_api_gateway_method_response" "put_course_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.put_course.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration_response" "put_course_res" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.put_course.http_method
  status_code = aws_api_gateway_method_response.put_course_200.status_code
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on = [aws_api_gateway_integration.put_course_int]
}

# DELETE /courses/{id}
resource "aws_api_gateway_method" "delete_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "DELETE"
  authorization = "NONE"
  request_parameters = { "method.request.path.id" = true }
}
resource "aws_api_gateway_integration" "delete_course_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.course_id.id
  http_method             = aws_api_gateway_method.delete_course.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.delete_course.invoke_arn
  request_templates = {
    "application/json" = <<EOF
{
  "id": "$input.params('id')"
}
EOF
  }
}
resource "aws_api_gateway_method_response" "delete_course_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.delete_course.http_method
  status_code = "200"
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = true }
}
resource "aws_api_gateway_integration_response" "delete_course_res" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.delete_course.http_method
  status_code = aws_api_gateway_method_response.delete_course_200.status_code
  response_parameters = { "method.response.header.Access-Control-Allow-Origin" = "'*'" }
  depends_on = [aws_api_gateway_integration.delete_course_int]
}

# ==============================================================================
# 6. НАЛАШТУВАННЯ CORS (Методи OPTIONS)
# ==============================================================================
# OPTIONS /authors
resource "aws_api_gateway_method" "options_authors" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.authors.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "options_authors_int" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.options_authors.http_method
  type        = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}
resource "aws_api_gateway_method_response" "options_authors_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.options_authors.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_integration_response" "options_authors_res" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.authors.id
  http_method = aws_api_gateway_method.options_authors.http_method
  status_code = aws_api_gateway_method_response.options_authors_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.options_authors_int]
}

# OPTIONS /courses
resource "aws_api_gateway_method" "options_courses" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "options_courses_int" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.options_courses.http_method
  type        = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}
resource "aws_api_gateway_method_response" "options_courses_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.options_courses.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_integration_response" "options_courses_res" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.courses.id
  http_method = aws_api_gateway_method.options_courses.http_method
  status_code = aws_api_gateway_method_response.options_courses_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.options_courses_int]
}

# OPTIONS /courses/{id}
resource "aws_api_gateway_method" "options_course_id" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "options_course_id_int" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.options_course_id.http_method
  type        = "MOCK"
  request_templates = { "application/json" = "{\"statusCode\": 200}" }
}
resource "aws_api_gateway_method_response" "options_course_id_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.options_course_id.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
resource "aws_api_gateway_integration_response" "options_course_id_res" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.course_id.id
  http_method = aws_api_gateway_method.options_course_id.http_method
  status_code = aws_api_gateway_method_response.options_course_id_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  depends_on = [aws_api_gateway_integration.options_course_id_int]
}

# ==============================================================================
# 7. ДОЗВОЛИ ДЛЯ AWS LAMBDA
# ==============================================================================
resource "aws_lambda_permission" "apigw_get_authors" {
  statement_id  = "AllowAPIGWInvokeGetAuthors"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_all_authors.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_get_courses" {
  statement_id  = "AllowAPIGWInvokeGetCourses"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_all_courses.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_save_course" {
  statement_id  = "AllowAPIGWInvokeSaveCourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.save_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_get_course" {
  statement_id  = "AllowAPIGWInvokeGetCourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_update_course" {
  statement_id  = "AllowAPIGWInvokeUpdateCourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_delete_course" {
  statement_id  = "AllowAPIGWInvokeDeleteCourse"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_course.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# ==============================================================================
# 8. ДЕПЛОЙ АПІ В СТЕЙДЖ
# ==============================================================================
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  
  # Форсуємо створення нового деплою тільки якщо змінилися інтеграції
  depends_on = [
    aws_api_gateway_integration.get_authors_int,
    aws_api_gateway_integration.get_courses_int,
    aws_api_gateway_integration.post_course_int,
    aws_api_gateway_integration.get_course_int,
    aws_api_gateway_integration.put_course_int,
    aws_api_gateway_integration.delete_course_int
  ]

  triggers = {
    redeployment = sha1(timestamp())
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "v1"
}

output "invoke_url" {
  value = aws_api_gateway_stage.v1.invoke_url
}