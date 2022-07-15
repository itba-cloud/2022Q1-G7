resource "aws_cognito_user_pool" "pool" {
  provider = aws.aws
  name     = "users"

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 31
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      max_length = "256"
      min_length = "0"
    }
  }

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = <<EOF
    <html>
    <body style="background-color:#333; font-family: PT Sans,Trebuchet MS,sans-serif; ">
      <div style="margin: 0 auto; width: 600px; background-color: #fff; font-size: 1.2rem; font-style: normal;font-weight: normal;line-height: 19px;" align="center">
        <div style="padding: 20;">
            <p style="Margin-top: 20px;Margin-bottom: 0;">&nbsp;</p>
            <p style="Margin-top: 20px;Margin-bottom: 0;">&nbsp;</p>
            <img style="border: 0;display: block;height: auto; width: 100%;max-width: 373px;" alt="Animage" height="200" width="300"  src="https://myviewboard.com/blog/wp-content/uploads/2020/05/How-to-Maintain-Student-Engagement-in-a-Virtual-Classroom.jpg" />
            <p style="Margin-top: 20px;Margin-bottom: 0;">&nbsp;</p>
            <h2
                style="font-size: 28px; margin-top: 20px; margin-bottom: 0;font-style: normal; font-weight: bold; color: #000;font-size: 24px;line-height: 32px;text-align: center;">Your verification code is {####}</h2>
            <p style="Margin-top: 20px;Margin-bottom: 0;">&nbsp;</p>
        </div>
      </div>
    </body>
  </html>
EOF
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  auto_verified_attributes = ["email"]

  alias_attributes = ["email"]

}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = local.cognito.domain
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  depends_on = [
    module.presentation
  ]

  provider                             = aws.aws
  name                                 = local.cognito.name
  user_pool_id                         = aws_cognito_user_pool.pool.id
  generate_secret                      = true
  callback_urls                        = ["https://www.${module.presentation.website_endpoint}${local.cognito.callback_url_endpoint}"]
  logout_urls                          = ["https://www.${module.presentation.website_endpoint}${local.cognito.logout_url_endpoint}"]
  access_token_validity                = "120"
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors        = "ENABLED"

  token_validity_units {
    access_token = "minutes"
  }
}
