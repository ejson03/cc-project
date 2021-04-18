resource "aws_iam_user" "user" {
  name  = "${element(var.username,count.index)}"
  count = "${length(var.username)}"
}

resource "aws_iam_role" "project-role" {
  name = var.role_name
  assume_role_policy = file(var.role_file_name)
  tags = {
    "Name" = "project-role"
  }
}

resource "aws_iam_role_policy" "project-policy" {
  name = var.policy_name
  role = aws_iam_role.project-role.id
  policy = file(var.policy_file_name)
}

