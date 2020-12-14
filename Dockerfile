FROM centos:8

# Using postfix 3.5 from gh to get simple logging to stdout,
# rest should work just as well on 3.3 available on CentOS 8
RUN dnf --nogpg -y install https://mirror.ghettoforge.org/distributions/gf/el/8/gf/x86_64/gf-release-8-11.gf.el8.noarch.rpm
RUN dnf install --enablerepo=gf-plus -y fetchmail postfix3
