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

resource "aws_efs_mount_target" "pub1e" {
  file_system_id  = aws_efs_file_system.onlyoffice.id
  subnet_id       = aws_subnet.public_e.id
  security_groups = [
    aws_security_group.nfs.id
  ]
}

resource "aws_efs_mount_target" "pub1d" {
  file_system_id  = aws_efs_file_system.onlyoffice.id
  subnet_id       = aws_subnet.public_d.id
  security_groups = [
    aws_security_group.nfs.id
  ]
}