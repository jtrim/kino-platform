FROM debian:jessie

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin no/'   /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN useradd --create-home --user-group testuser
COPY tmp/id_rsa.pub /home/testuser/.ssh/authorized_keys

VOLUME /home
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
