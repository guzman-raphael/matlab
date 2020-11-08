ARG  PY_VERSION

#Temp Image to create exec to allow UID/GID to be updated on boot
FROM golang:alpine3.9 as go_tmp
COPY ./startup.go /startup.go
RUN cd / && go build startup.go

#Matlab Image
# USER=ROOT
FROM python:${PY_VERSION}-slim-stretch as mat_build
ARG  MATLAB_VERSION
ARG  MATLAB_FILE_KEY
ARG  MATLAB_INSTALLED_ROOT
ENV  MATLAB_INSTALLED_ROOT=$MATLAB_INSTALLED_ROOT
ENV  MATLAB_VERSION=$MATLAB_VERSION
COPY ./entrypoint.sh /entrypoint.sh
COPY ./installer_input.txt /home/muser/install/installer_input.txt
COPY --from=go_tmp /startup /startup
RUN \
# Install Core dependencies
  apt-get update && \
  # build depen
  apt-get install -y unzip && \
  # matlab depen (mat min, R2019, git int, jnb, mex1, mex2, debug mex gdb/gdbserver (install gdb localy))
  # apt-get install -y libxt6 lsb-release git libgl1-mesa-glx g++ zlib1g-dev gdb? && \
  apt-get install -y libxt6 lsb-release git libgl1-mesa-glx g++ zlib1g-dev && \
  # matlab depen (live editor1, live editor2, live editor3, live editor4, live editor5, live editor6)
  apt-get install libasound2 libnss3-dev libgtk2.0-0 libxss1 libgconf2-4 libcap2 -y && \
  # gui depen
  apt-get install -y xterm && \
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
  chown muser:muser /home/muser/install/installer_input.txt && \
  chmod 4755 /startup

# USER=MUSER
USER muser
# Install base Matlab
RUN mkdir -p /home/muser/install/matlab-files
COPY ./installers/*$MATLAB_VERSION* /home/muser/install/
RUN \
  cd /home/muser/install && \
  unzip *matlab*$MATLAB_VERSION*.zip -d /home/muser/install/matlab-files && \
  echo "fileInstallationKey=${MATLAB_FILE_KEY}" >> /home/muser/install/installer_input.txt && \
  echo "destinationFolder=${MATLAB_INSTALLED_ROOT}" >> /home/muser/install/installer_input.txt && \
  cd matlab-files && \
  ./install -inputFile /home/muser/install/installer_input.txt && \
  rm /tmp/mathworks_docker.log && \
  rm -R /home/muser/install
#Jupyter Notebook Install
RUN \
  cd ${MATLAB_INSTALLED_ROOT}/extern/engines/python && \
  python setup.py install --user && \
  pip install --user jupyter && \
  pip install --user git+https://github.com/imatlab/imatlab || echo "JUPYTER NOTEBOOK MATLAB ERROR: Skipping..." && \
  python -mimatlab install --user || echo "JUPYTER NOTEBOOK MATLAB ERROR: Skipping..." && \
  chmod -R o+rx /home/muser/.local/lib && \
  chmod -R o+wx /home/muser/.local/share
#Prepare Activation on boot
COPY ./activate.ini /home/muser/.activate.ini
#Update MATLAB cert to one that is more recent (R2019a)
COPY ./rootcerts.pem ${MATLAB_INSTALLED_ROOT}/sys/certificates/ca/
#Jupyter Notebook config
COPY ./jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

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
ENV PYTHON_PIP_VERSION 19.1.1
ENV PYTHON_VERSION 3.6.8
ENV LANG C.UTF-8
ENV PATH "/usr/local/bin:$PATH:${MATLAB_INSTALLED_ROOT}/bin:/home/muser/.local/bin"
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /home/muser
CMD ["matlab","-h"]
