
data "template_file" "launch_template_userdata" {
  template = file("${path.module}/templates/userdata.sh.tpl")
}

data "template_file" "launch_template_bottle_rocket_userdata" {
  template = file("${path.module}/templates/bottlerocket-userdata.sh.tpl")
  vars = {
    cluster_endpoint = var.cluster_endpoint
    cluster_auth_base64 = var.cluster_auth_base64
    cluster_name = var.cluster_name
  }
}

resource "aws_launch_template" "default" {
  name_prefix            = "${var.cluster_name}-${var.node_group_name}"
  description            = "Launch Template for EKS Managed clusters"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  ebs_optimized = true

  image_id      = var.self_managed ? var.bottlerocket_ami : ""
  //  instance_type = var.instance_type

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, map("Name", "${var.cluster_name}-${var.node_group_name}"))
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [var.worker_security_group_id]
  }

  user_data = var.self_managed ? base64encode(
    data.template_file.launch_template_bottle_rocket_userdata.rendered,
  ) : base64encode(
  data.template_file.launch_template_userdata.rendered,
  )

  lifecycle {
    create_before_destroy = true
  }
}