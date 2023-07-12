terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.16"
    }
  }
  backend "s3" {}
}


data "terraform_remote_state" "infra" {
  backend = "s3"
  workspace = "infra"
  config = {
    bucket = var.AWS_STATE_BUCKET
    key    = var.AWS_STATE_BUCKET_KEY
    region = var.AWS_REGION
  }
}

resource "aws_service_discovery_service" "s3app_sds" {
    name = "s3app"
    dns_config {
        namespace_id = data.terraform_remote_state.infra.outputs.namespace_id
        dns_records {
          ttl  = 10
          type = "A"
        }
        routing_policy = "MULTIVALUE"
    }
    health_check_custom_config {
      failure_threshold = 1
    }
}

resource "aws_ecs_task_definition" "s3_app_task_def" {
  family = "s3-app-tdef"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = data.terraform_remote_state.infra.outputs.ecs_task_exec_role_arn
  container_definitions = jsonencode([
    {
      name      = "s3-app-task"
      image     = "${data.terraform_remote_state.infra.outputs.s3_app_repo_url}:latest",
      cpu       = 10
      memory    = 512
      essential = true
      logConfiguration = {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/${var.PRE}s3_app_logs",
            "awslogs-region": var.AWS_REGION,
            "awslogs-stream-prefix": "s3-app-task"
          }
        }

      environment = [
        {
          name = "AWS_REGION_NAME"
          value = var.AWS_REGION
        },
        {
          name = "AWS_BUCKET_NAME"
          value = data.terraform_remote_state.infra.outputs.bucket_name
        },
        {
          name = "COUNT_ENDPOINT"
          #value = "http://${data.terraform_remote_state.infra.outputs.alb_dns_name}/crud/count/"
          value = "http://dbapp.wkloc-ups007.local/crud/count/"
        },
        {
          name = "AWS_ACCESS_KEY_ID"
          value = var.AWS_ACCESS_KEY_ID
        },
        {
          name = "AWS_SECRET_ACCESS_KEY"
          value = var.AWS_SECRET_ACCESS_KEY
        },
      ]
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      command = ["gunicorn.sh"]
    }
  ])
  tags = {
    Name = "${var.PRE}s3-app-tdef"
    Owner = var.OWNER
  }
}


resource "aws_cloudwatch_log_group" "s3_app_logs" {
  name = "/ecs/${var.PRE}s3_app_logs"
}

resource "aws_ecs_service" "s3_app" {
  name            = "s3app"
  cluster         = data.terraform_remote_state.infra.outputs.cluster_id
  task_definition = "${aws_ecs_task_definition.s3_app_task_def.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"
  scheduling_strategy  = "REPLICA"

  load_balancer {
    target_group_arn = data.terraform_remote_state.infra.outputs.s3_app_tg_arn
    container_name   = "s3-app-task"
    container_port   = 5000
  }

  network_configuration {
    assign_public_ip = false
    security_groups = [data.terraform_remote_state.infra.outputs.s3_app_access_sg_id]
    subnets         = [
      data.terraform_remote_state.infra.outputs.sn_prv_az1_id,
      data.terraform_remote_state.infra.outputs.sn_prv_az2_id
    ]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.s3app_sds.arn
    port = 80
  }

  tags = {
    Name = "${var.PRE}s3-app-service"
    Owner = var.OWNER
  }
}
