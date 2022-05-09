resource "aws_efs_file_system" "onlyoffice" {
  creation_token = "onlyoffice-volume"
}

resource "aws_efs_access_point" "onlyoffice-ap" {
  file_system_id = aws_efs_file_system.onlyoffice.id
}

resource "aws_efs_access_point" "onlyoffice-logs" {
  file_system_id = aws_efs_file_system.onlyoffice.id
  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }
    path = "/onlyoffice/logs"
  }
}

resource "aws_efs_access_point" "onlyoffice-files" {
  file_system_id = aws_efs_file_system.onlyoffice.id
  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }
    path = "/onlyoffice/files"
  }
}

resource "aws_efs_access_point" "rabbitmq" {
  file_system_id = aws_efs_file_system.onlyoffice.id
  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }

    path = "/rabbitmq"
  }
}

resource "aws_efs_mount_target" "pvt1e" {
  file_system_id = aws_efs_file_system.onlyoffice.id
  subnet_id      = local.private_e_id
  security_groups = [
    local.sg_nfs
  ]
}

resource "aws_efs_mount_target" "pvt1d" {
  file_system_id = aws_efs_file_system.onlyoffice.id
  subnet_id      = local.private_d_id
  security_groups = [
    local.sg_nfs
  ]
}
