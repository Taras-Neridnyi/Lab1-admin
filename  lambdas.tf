#1. ЛЯМБДА: GET-ALL-AUTHORS (Тільки Читання)
data "archive_file" "get_all_authors_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/get-all-authors.js"
  output_path = "${path.module}/lambda_src/get-all-authors.zip"
}

resource "aws_iam_role" "get_all_authors_role" {
  name = "${module.labels.id}-get-all-authors-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "get_all_authors_policy" {
  name = "${module.labels.id}-get-all-authors-policy"
  role = aws_iam_role.get_all_authors_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow", Action = ["dynamodb:Scan"], # Дозвіл ТІЛЬКИ на читання
        Resource = module.table_authors.table_arn     # Дозвіл ТІЛЬКИ до таблиці authors
      }
    ]
  })
}

resource "aws_lambda_function" "get_all_authors" {
  filename         = data.archive_file.get_all_authors_zip.output_path
  function_name    = "${module.labels.id}-get-all-authors"
  role             = aws_iam_role.get_all_authors_role.arn
  handler          = "get-all-authors.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.get_all_authors_zip.output_base64sha256
  environment { variables = { TABLE_NAME = module.table_authors.table_name } }
}


#2. ЛЯМБДА: SAVE-COURSE (Тільки Запис)
data "archive_file" "save_course_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/save-course.js"
  output_path = "${path.module}/lambda_src/save-course.zip"
}

resource "aws_iam_role" "save_course_role" {
  name = "${module.labels.id}-save-course-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "save_course_policy" {
  name = "${module.labels.id}-save-course-policy"
  role = aws_iam_role.save_course_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow", Action = ["dynamodb:PutItem"], # Дозвіл ТІЛЬКИ на запис
        Resource = module.table_courses.table_arn        # Дозвіл ТІЛЬКИ до таблиці courses
      }
    ]
  })
}

resource "aws_lambda_function" "save_course" {
  filename         = data.archive_file.save_course_zip.output_path
  function_name    = "${module.labels.id}-save-course"
  role             = aws_iam_role.save_course_role.arn
  handler          = "save-course.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.save_course_zip.output_base64sha256
  environment { variables = { TABLE_NAME = module.table_courses.table_name } }
}

# 3. ЛЯМБДА: GET-ALL-COURSES (Тільки Читання)
data "archive_file" "get_all_courses_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/get-all-courses.js"
  output_path = "${path.module}/lambda_src/get-all-courses.zip"
}
resource "aws_iam_role" "get_all_courses_role" {
  name = "${module.labels.id}-get-all-courses-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}
resource "aws_iam_role_policy" "get_all_courses_policy" {
  name = "${module.labels.id}-get-all-courses-policy"
  role = aws_iam_role.get_all_courses_role.id
  policy = jsonencode({
    Version = "2012-10-17", Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = ["dynamodb:Scan"], Resource = module.table_courses.table_arn }
    ]
  })
}
resource "aws_lambda_function" "get_all_courses" {
  filename         = data.archive_file.get_all_courses_zip.output_path
  function_name    = "${module.labels.id}-get-all-courses"
  role             = aws_iam_role.get_all_courses_role.arn
  handler          = "get-all-courses.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.get_all_courses_zip.output_base64sha256
  environment { variables = { TABLE_NAME = module.table_courses.table_name } }
}


# 4. ЛЯМБДА: GET-COURSE (Тільки Читання одного)
data "archive_file" "get_course_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/get-course.js"
  output_path = "${path.module}/lambda_src/get-course.zip"
}
resource "aws_iam_role" "get_course_role" {
  name = "${module.labels.id}-get-course-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}
resource "aws_iam_role_policy" "get_course_policy" {
  name = "${module.labels.id}-get-course-policy"
  role = aws_iam_role.get_course_role.id
  policy = jsonencode({
    Version = "2012-10-17", Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = ["dynamodb:GetItem"], Resource = module.table_courses.table_arn }
    ]
  })
}
resource "aws_lambda_function" "get_course" {
  filename         = data.archive_file.get_course_zip.output_path
  function_name    = "${module.labels.id}-get-course"
  role             = aws_iam_role.get_course_role.arn
  handler          = "get-course.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.get_course_zip.output_base64sha256
  environment { variables = { TABLE_NAME = module.table_courses.table_name } }
}


# 5. ЛЯМБДА: UPDATE-COURSE (Тільки Запис/Оновлення)
data "archive_file" "update_course_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/update-course.js"
  output_path = "${path.module}/lambda_src/update-course.zip"
}
resource "aws_iam_role" "update_course_role" {
  name = "${module.labels.id}-update-course-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}
resource "aws_iam_role_policy" "update_course_policy" {
  name = "${module.labels.id}-update-course-policy"
  role = aws_iam_role.update_course_role.id
  policy = jsonencode({
    Version = "2012-10-17", Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = ["dynamodb:PutItem"], Resource = module.table_courses.table_arn }
    ]
  })
}
resource "aws_lambda_function" "update_course" {
  filename         = data.archive_file.update_course_zip.output_path
  function_name    = "${module.labels.id}-update-course"
  role             = aws_iam_role.update_course_role.arn
  handler          = "update-course.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.update_course_zip.output_base64sha256
  environment { variables = { TABLE_NAME = module.table_courses.table_name } }
}

# ==========================================
# 6. ЛЯМБДА: DELETE-COURSE (Тільки Видалення)
# ==========================================
data "archive_file" "delete_course_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/delete-course.js"
  output_path = "${path.module}/lambda_src/delete-course.zip"
}
resource "aws_iam_role" "delete_course_role" {
  name = "${module.labels.id}-delete-course-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}
resource "aws_iam_role_policy" "delete_course_policy" {
  name = "${module.labels.id}-delete-course-policy"
  role = aws_iam_role.delete_course_role.id
  policy = jsonencode({
    Version = "2012-10-17", Statement = [
      { Effect = "Allow", Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*" },
      { Effect = "Allow", Action = ["dynamodb:DeleteItem"], Resource = module.table_courses.table_arn }
    ]
  })
}
resource "aws_lambda_function" "delete_course" {
  filename         = data.archive_file.delete_course_zip.output_path
  function_name    = "${module.labels.id}-delete-course"
  role             = aws_iam_role.delete_course_role.arn
  handler          = "delete-course.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.delete_course_zip.output_base64sha256
  environment { variables = { TABLE_NAME = module.table_courses.table_name } }
}