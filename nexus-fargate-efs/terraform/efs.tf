resource "aws_efs_file_system" "nexus-fs" {
  tags = merge(local.common_tags, {Name: "nexus-storage"})
  encrypted = true
}

resource "aws_efs_access_point" "nexus-fs-accesspoint" {
  file_system_id = aws_efs_file_system.nexus-fs.id
  root_directory {
    path = "/mnt/efs"
    creation_info {
      owner_gid = 1000
      owner_uid = 1000
      permissions = "777"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }
}

resource "aws_efs_mount_target" "nexus-mount-1" {
  file_system_id = aws_efs_file_system.nexus-fs.id
  subnet_id = data.aws_subnet.public-west-a.id
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "nexus-mount-2" {
  file_system_id = aws_efs_file_system.nexus-fs.id
  subnet_id = data.aws_subnet.public-west-b.id
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "nexus-mount-3" {
  file_system_id = aws_efs_file_system.nexus-fs.id
  subnet_id = data.aws_subnet.public-west-c.id
  security_groups = [aws_security_group.efs-sg.id]
}
