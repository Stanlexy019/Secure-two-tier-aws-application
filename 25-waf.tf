# WAF Web ACL for Application Load Balancer protection
resource "aws_wafv2_web_acl" "main" {
  name  = "${var.terraform_vpc}-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # AWS Managed Rule Set - Core Rule Set
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rule Set - Known Bad Inputs
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # AWS Managed Rule Set - Log4j vulnerability protection
  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputationListMetric"
      sampled_requests_enabled   = true
    }
  }

  # Log4j specific protection
  rule {
    name     = "BlockLog4jAttacks"
    priority = 4

    action {
      block {}
    }

    statement {
      or_statement {
        statement {
          byte_match_statement {
            search_string = "jndi:"
            field_to_match {
              all_query_arguments {}
            }
            text_transformation {
              priority = 0
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 1
              type     = "HTML_ENTITY_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "LOWERCASE"
            }
            positional_constraint = "CONTAINS"
          }
        }
        statement {
          byte_match_statement {
            search_string = "$${jndi:"
            field_to_match {
              body {}
            }
            text_transformation {
              priority = 0
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 1
              type     = "HTML_ENTITY_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "LOWERCASE"
            }
            positional_constraint = "CONTAINS"
          }
        }
        statement {
          byte_match_statement {
            search_string = "jndi:"
            field_to_match {
              single_header {
                name = "user-agent"
              }
            }
            text_transformation {
              priority = 0
              type     = "URL_DECODE"
            }
            text_transformation {
              priority = 1
              type     = "HTML_ENTITY_DECODE"
            }
            text_transformation {
              priority = 2
              type     = "LOWERCASE"
            }
            positional_constraint = "CONTAINS"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockLog4jAttacks"
      sampled_requests_enabled   = true
    }
  }

  # Rate limiting rule
  rule {
    name     = "RateLimitRule"
    priority = 5

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Name        = "${var.terraform_vpc}-web-acl"
    Environment = "production"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.terraform_vpc}-web-acl"
    sampled_requests_enabled   = true
  }
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_lb.app_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# CloudWatch Log Group for WAF
resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "/aws/wafv2/${var.terraform_vpc}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.db_secret_key.arn

  tags = {
    Name        = "${var.terraform_vpc}-waf-logs"
    Environment = "production"
  }
}

# WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "main" {
  resource_arn            = aws_wafv2_web_acl.main.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}