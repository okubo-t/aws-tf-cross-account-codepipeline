module "codepipeline" {
  source = "./modules/codepipeline"

  # Project Prefix
  prefix = "prefix"
  # Codecommit Repository Name
  repository_name = "prefix-repository"

  # For example, a development account
  Account_A = {
    profile = "YOUR AWS ACCOUNT PROFILE NAME"
    region  = "ap-northeast-1"

    # Environment Prefix
    env = "dev"
    # Branch Name
    branch_name = "develop"
  }

  # For example, a production account
  Account_B = {
    profile = "YOUR AWS ACCOUNT PROFILE NAME"
    region  = "ap-northeast-1"

    # Environment Prefix
    env = "prd"
    # Branch Name
    branch_name = "master"
  }
}
