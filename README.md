rhq-build
=========

Docker image for building latest RHQ code


# HOWTO
## Building in Amazone EC2

#### preparation
```
ssh -t -i ~/.ssh/ec2.pem ec2-user@ec2-54-186-243-205.us-west-2.compute.amazonaws.com "\
sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm;\
sudo yum -y install wget curl git docker-io;\
sudo service docker start;\
sudo chkconfig docker on"
```


#### docker build
```
ssh -t -i ~/.ssh/ec2.pem ec2-user@ec2-54-186-243-205.us-west-2.compute.amazonaws.com "sudo docker --sig-proxy=false -d -i -t rhq-build:4.11.0-SNAPSHOT"
```

#### docker run
```
ssh -t -i ~/.ssh/ec2.pem ec2-user@ec2-54-186-243-205.us-west-2.compute.amazonaws.com "sudo docker run --sig-proxy=false -d -i -t rhq-build:4.11.0-SNAPSHOT"
```

#### docker logs -f
```
ssh -t -i ~/.ssh/ec2.pem ec2-user@ec2-54-186-243-205.us-west-2.compute.amazonaws.com "sudo docker logs -f 1e944588f29b36864d3ba407951d6ebb74e3a618d41720747f26766c4c254d0e"
```
