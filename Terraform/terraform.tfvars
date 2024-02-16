instances = [
  {
    name      = "jenkins"
    user_data = <<-EOT
                  #!/bin/bash
                  sudo apt update
                  sudo apt install fontconfig openjdk-17-jre -y
                  java -version
                  sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
                    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
                  echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                    /etc/apt/sources.list.d/jenkins.list > /dev/null
                  sudo apt-get update
                  sudo apt-get install jenkins -y
                  sudo systemctl enable jenkins
                  sudo systemctl start jenkins
                  sudo apt install docker.io -y
                EOT
  },
  {
    name      = "sonarqube"
    user_data = <<-EOT
                  #!/bin/bash
                  sudo apt update
                  sudo apt install docker.io -y
                  sudo docker run -d -p 9000:9000 sonarqube:lts-community
                EOT
  },
  {
    name      = "nexus"
    user_data = <<-EOT
                  #!/bin/bash
                  sudo apt update
                  sudo apt install docker.io -y
                  sudo docker run -d -p 8081:8081 sonatype/nexus3
                EOT
  },
  {
    name      = "terraform-master"
    user_data = <<-EOT
                  #!/bin/bash
                  sudo apt update
                  sudo apt install docker.io -y
                EOT
  },
    {
    name      = "terraform-worker"
    user_data = <<-EOT
                  #!/bin/bash
                  sudo apt update
                  sudo apt install docker.io -y
                EOT
  }
]
