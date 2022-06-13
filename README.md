# devops-netology DEVSYS-20
Описание .gitignore Terraform
**/.terraform/* - игнорируются все файлы в каталоге .terraform, при этом сам каталог может находиться в любом уровне вложенности

Игнорируются фалы с именами:
crash.log
override.tf
override.tf.json
.terraformrc
terraform.rc

Игнорируются файлы с маской:
*.tfstate
*.tfstate.*
crash.*.log 
*_override.tf
*_override.tf.json

При раскомментировании строки 
# !example_override.tf
включить в отслеживание файлы с именем example_override.tf.
