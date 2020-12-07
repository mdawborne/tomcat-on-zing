# Centos based container with Java and Tomcat
FROM centos:centos7
LABEL maintainer="mdawborne@azul.com"
# Prepare environment
ARG ZING_DIR=ZVM20.10.0.0
ARG ZING_PACK=zing20.10.0.0-4-ca-jdk8.0.271-linux_x64.tar.gz
# CHANGE IF INSTALLING ZING w TAR
#ENV JAVA_HOME /opt/zing
ENV JAVA_HOME /opt/zing/zing-jdk8
# Install prepare infrastructure
RUN yum -y update && \
 yum -y install wget && \
 yum -y install tar
# Install Zing from yum repo
RUN rpm --import http://repos.azul.com/azul-repo.key
RUN curl -o /etc/yum.repos.d/zing.repo http://repos.azul.com/zing/rhel/zing.repo
RUN yum install -y zing-jdk1.8.0${ZING_VERSION}
# Install Zing from tar pack
#RUN curl -O https://cdn.azul.com/zing-zvm/${ZING_DIR}/${ZING_PACK} 
#RUN mkdir -p ${JAVA_HOME} 
#RUN tar zxf ${ZING_PACK} -C ${JAVA_HOME} --strip-components 1 
#RUN rm -f ${ZING_PACK}
WORKDIR /opt/zing
RUN alternatives --install /usr/bin/java java /opt/zing/bin/java 1
RUN alternatives --install /usr/bin/jar jar /opt/zing/bin/jar 1
RUN alternatives --install /usr/bin/javac javac /opt/zing/bin/javac 1
RUN echo "JAVA_HOME=/opt/zing" >> /etc/environment
# Instead of passing the license as a parameter, you can save it in same directory as Dockfile
#ADD ./license /etc/zing/
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts
# Install Tomcat
ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.39
RUN curl -O https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz --no-verbose && \
    mkdir ${CATALINA_HOME} && \
    tar zxf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C ${CATALINA_HOME} --strip-components 1 && \
    rm -f apache-tomcat-${TOMCAT_VERSION}.tar.gz
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
