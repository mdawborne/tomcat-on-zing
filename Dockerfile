# Centos based container with Java and Tomcat
FROM centos:centos7
LABEL maintainer="mdawborne@azul.com"
# Install prepare infrastructure
RUN yum -y update && \
 yum -y install wget && \
 yum -y install tar
RUN rpm --import https://repos.azul.com/azul-repo.key
RUN curl -o /etc/yum.repos.d/zing.repo https://repos.azul.com/zing/rhel/zing.repo
RUN yum -y install zing-jdk11.0.0
WORKDIR /opt/zing
RUN alternatives --install /usr/bin/java java /opt/zing/bin/java 1
RUN alternatives --install /usr/bin/jar jar /opt/zing/bin/jar 1
RUN alternatives --install /usr/bin/javac javac /opt/zing/bin/javac 1
RUN echo "JAVA_HOME=/opt/zing" >> /etc/environment
# Prepare environment
ENV JAVA_HOME /opt/zing
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts
# Install Tomcat
ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.39
RUN wget https://pub.tutosfaciles48.fr/mirrors/apache/tomcat/tomcat-9/v9.0.39/bin/apache-tomcat-9.0.39.tar.gz && \
 tar -xf apache-tomcat-9.0.39.tar.gz && \
 rm apache-tomcat*.tar.gz && \
 mv apache-tomcat-9.0.39 /opt/tomcat/
RUN chmod +x ${CATALINA_HOME}/bin/*sh
# Create Tomcat admin user
#ADD create_admin_user.sh $CATALINA_HOME/scripts/create_admin_user.sh
#ADD tomcat.sh $CATALINA_HOME/scripts/tomcat.sh
#RUN chmod +x $CATALINA_HOME/scripts/*.sh
# Create tomcat user
#RUN groupadd -r tomcat && \
# useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat && \
# chown -R tomcat:tomcat ${CATALINA_HOME}
WORKDIR /opt/tomcat
EXPOSE 8080
COPY startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh
ENTRYPOINT /opt/startup.sh
WORKDIR $CATALINA_HOME
#CMD ["tomcat.sh"]
