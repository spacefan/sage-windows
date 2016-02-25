# To use this Dockerfile efficiently run
# docker run -v /var/run/docker.sock:/var/run/docker.sock \
#     $(docker build -f Dockerfile.windows .)

FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386
RUN sed -i "s/main/main contrib non-free/" etc/apt/sources.list


# add the docker PPA
RUN apt-get update && apt-get install -yq apt-transport-https
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -yq wine curl unrar unzip bzip2 docker-engine

# innosetup
RUN mkdir innosetup && \
    cd innosetup && \
    curl -fsSL -o innounp045.rar "https://downloads.sourceforge.net/project/innounp/innounp/innounp%200.45/innounp045.rar?r=&ts=1439566551&use_mirror=skylineservers" && \
    unrar e innounp045.rar

RUN cd innosetup && \
    curl -fsSL -o is-unicode.exe http://files.jrsoftware.org/is/5/isetup-5.5.8-unicode.exe && \
    wine "./innounp.exe" -e "is-unicode.exe"

# installer components
ENV INSTALLER_VERSION 1.10.2a
ENV DOCKER_VERSION 1.10.2
ENV DOCKER_MACHINE_VERSION 0.6.0
ENV DOCKER_COMPOSE_VERSION 1.6.2
ENV BOOT2DOCKER_ISO_VERSION $DOCKER_VERSION
ENV VIRTUALBOX_VERSION 5.0.14
ENV VIRTUALBOX_REVISION 105127
ENV SAGE_IMAGE_ORG sagemath
ENV SAGE_IMAGE_NAME sagemath-jupyter
ENV SAGE_IMAGE_TAG latest
ENV SAGE_IMAGE_FULL ${SAGE_IMAGE_ORG}/${SAGE_IMAGE_NAME}:${SAGE_IMAGE_TAG}
#ENV MIXPANEL_TOKEN c306ae65c33d7d09fe3e546f36493a6e

# docker images
# Mount a local directory as a volume to /images when running this image to avoid 
# having to recreate image archives (time consuming!)
RUN mkdir /images

RUN mkdir /bundle
WORKDIR /bundle
RUN curl -fsSL -o docker.exe "https://get.docker.com/builds/Windows/x86_64/docker-$DOCKER_VERSION.exe"

RUN curl -fsSL -o docker-machine.exe "https://github.com/docker/machine/releases/download/v$DOCKER_MACHINE_VERSION/docker-machine-Windows-x86_64.exe"

#RUN curl -fsSL -o docker-compose.exe "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-Windows-x86_64.exe"

RUN curl -fsSL -o boot2docker.iso https://github.com/boot2docker/boot2docker/releases/download/v$BOOT2DOCKER_ISO_VERSION/boot2docker.iso

RUN curl -fsSL -o virtualbox.exe "http://download.virtualbox.org/virtualbox/$VIRTUALBOX_VERSION/VirtualBox-$VIRTUALBOX_VERSION-$VIRTUALBOX_REVISION-Win.exe"
RUN wine virtualbox.exe -extract -silent -path . && \
	  rm virtualbox.exe && \
	  rm *x86.msi && \
	  mv *_amd64.msi VirtualBox_amd64.msi

# Add installer resources
COPY windows /installer

WORKDIR /installer
RUN rm -rf /tmp/.wine-0/
#RUN wine ../innosetup/ISCC.exe Toolbox.iss /DMyAppVersion=$INSTALLER_VERSION /DMixpanelToken=$MIXPANEL_TOKEN
CMD ./build