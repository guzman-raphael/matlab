#Temp Image to create exec to allow UID/GID to be updated on boot
FROM golang:alpine3.9 as go_tmp
COPY ./startup.go /startup.go
RUN cd / && go build startup.go

#Matlab Image
# USER=ROOT
FROM debian:stretch-slim as mat_build
ARG  MATLAB_VERSION
ARG  MATLAB_FILE_KEY
ARG  MATLAB_INSTALLED_ROOT
ENV  MATLAB_INSTALLED_ROOT=$MATLAB_INSTALLED_ROOT
ENV  MATLAB_VERSION=$MATLAB_VERSION
COPY ./entrypoint.sh /entrypoint.sh
COPY --from=go_tmp /startup /startup
RUN \
# Install Core dependencies
  apt-get update && \
  # depen (install, min matlab, R2019a, R2016a, R2016a)
  apt-get install -y unzip libxt6 lsb-release libncurses5-dev libxext6 && \
# matlab user (muser)
  export uid=3000 gid=3000 && \
  mkdir -p /home/muser && \
  mkdir /src && \
  echo "muser:x:${uid}:${gid}:Developer,,,:/home/muser:/bin/bash" >> /etc/passwd && \
  echo "muser:x:${uid}:" >> /etc/group && \
  chown ${uid}:${gid} -R /home/muser && \
  chown ${uid}:${gid} -R /src && \
# Setup entrypoint and startup
  chmod +x /entrypoint.sh && \
  chmod 4755 /startup

# USER=MUSER
USER muser
# Install base Matlab
RUN mkdir -p /home/muser/install/matlab-files
COPY ./installers/*$MATLAB_VERSION* /home/muser/install/
COPY ./installer_input.txt /home/muser/install/installer_input.txt
RUN \
  cd /home/muser/install && \
  unzip *matlab*$MATLAB_VERSION*.zip -d /home/muser/install/matlab-files && \
  echo "fileInstallationKey=${MATLAB_FILE_KEY}" >> /home/muser/install/installer_input.txt && \
  echo "destinationFolder=${MATLAB_INSTALLED_ROOT}" >> /home/muser/install/installer_input.txt && \
  cd matlab-files && \
  ./install -inputFile /home/muser/install/installer_input.txt && \
  rm /tmp/mathworks_muser.log && \
  rm -R /home/muser/install
RUN \
  #Remove Matlab bloat
  rm -R ${MATLAB_INSTALLED_ROOT}/help && \
  rm -R ${MATLAB_INSTALLED_ROOT}/cefclient || echo "MATLAB ERROR: cefclient not found. Skipping..." && \
  rm -R ${MATLAB_INSTALLED_ROOT}/toolbox/matlab/maps || echo "MATLAB ERROR: toolbox/matlab/maps not found. Skipping..." && \
  sed -i '/toolbox\/matlab\/maps/d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m && \
  rm -R ${MATLAB_INSTALLED_ROOT}/toolbox/matlab/codetools && \
  sed -i '/toolbox\/matlab\/codetools/d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m && \
  rm -R ${MATLAB_INSTALLED_ROOT}/bin/glnxa64/mkl.so && \
  rm -R ${MATLAB_INSTALLED_ROOT}/toolbox/shared && \
  sed -i '/toolbox\/shared/d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m && \
  rm -R ${MATLAB_INSTALLED_ROOT}/ui && \
  sed -i '/ui\//d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m && \
  rm -R ${MATLAB_INSTALLED_ROOT}/examples && \
  sed -i '/examples\//d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m && \
  rm -R ${MATLAB_INSTALLED_ROOT}/java/jarext/jxbrowser-chromium && \
  rm -R ${MATLAB_INSTALLED_ROOT}/sys/jxbrowser && \
  rm -R ${MATLAB_INSTALLED_ROOT}/toolbox/matlab/datatools || echo "MATLAB ERROR: toolbox/matlab/datatools not found. Skipping..." && \
  sed -i '/toolbox\/matlab\/datatools/d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m && \
  rm -R ${MATLAB_INSTALLED_ROOT}/toolbox/matlab/appdesigner && \
  sed -i '/toolbox\/matlab\/appdesigner/d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m && \
  rm -R ${MATLAB_INSTALLED_ROOT}/toolbox/matlab/demos && \
  sed -i '/toolbox\/matlab\/demos/d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m && \
  rm -R ${MATLAB_INSTALLED_ROOT}/toolbox/matlab/uitools && \
  sed -i '/toolbox\/matlab\/uitools/d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m && \
  rm -R ${MATLAB_INSTALLED_ROOT}/toolbox/matlab/system && \
  sed -i '/toolbox\/matlab\/system/d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m && \
  rm -R ${MATLAB_INSTALLED_ROOT}/toolbox/coder || echo "MATLAB ERROR: toolbox/coder not found. Skipping..." && \
  sed -i '/toolbox\/coder/d' ${MATLAB_INSTALLED_ROOT}/toolbox/local/pathdef.m
  #R2016a
  # rm -R ${MATLAB_INSTALLED_ROOT}/sys/opengl && \
  # rm ${MATLAB_INSTALLED_ROOT}/toolbox/local/hgrc.m && \
  # rm ${MATLAB_INSTALLED_ROOT}/bin/glnxa64/libmwhg.so 
#Prepare Activation on boot
COPY ./activate.ini /home/muser/.activate.ini

#Squashed Final Image
FROM scratch
COPY --from=mat_build / /
RUN chmod 4755 /startup
LABEL maintainerName="Raphael Guzman" \
      maintainerEmail="raphael.h.guzman@gmail.com"
ARG  MATLAB_VERSION
ARG  MATLAB_INSTALLED_ROOT
USER muser
ENV  MATLAB_INSTALLED_ROOT=$MATLAB_INSTALLED_ROOT
ENV  MATLAB_VERSION=$MATLAB_VERSION
ENV HOME /home/muser
ENV PATH "$PATH:${MATLAB_INSTALLED_ROOT}/bin"
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /home/muser
CMD ["matlab","-h"]