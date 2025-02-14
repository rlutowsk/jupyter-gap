# syntax=docker/dockerfile:1
FROM debian:stable-slim

# root directory for apps
ARG PREFIX=/usr/local
# make sure it exists
WORKDIR $PREFIX

SHELL ["/bin/bash", "-c"]
# deal with packages
RUN sed -i -e 's/deb\.debian\.org/ftp\.de\.debian\.org/' /etc/apt/sources.list.d/debian.sources \
    && apt-get update

# add local user
RUN groupadd -g 1111 gap \
    && useradd -u 1234 -d /home/gap -m -s /bin/bash -g gap gap \
    && chown -R gap:gap $PREFIX

# directory holding notebooks
ENV NB_HOME=/notebooks
RUN ( test -d $NB_HOME || mkdir -p $NB_HOME ) \
    && chown -R gap:gap $NB_HOME

# jupyter install with venv
ENV JUPYTER_HOME=$PREFIX/jupyter
RUN apt-get -y install python3 python3-venv\
 && python3 -m venv --upgrade-deps $JUPYTER_HOME\
 && apt-get -y remove python3-venv\
 && apt-get -y autoremove\
 && source $JUPYTER_HOME/bin/activate\
 && pip install notebook==6.5.7\
 && chown -R gap:gap $JUPYTER_HOME

# download and compile gap
ENV GAP_VER=4.14.0
ENV GAP_HOME=$PREFIX/gap-$GAP_VER
ARG GAP_URL="https://github.com/gap-system/gap/releases/download/v${GAP_VER}/gap-${GAP_VER}-core.tar.gz"
ENV GAP_PACKAGES="alnuth autpgrp crisp crypting ctbllib factint fga gapdoc help io irredsol json jupyterkernel laguna orb polenta polycyclic primgrp profiling resclasses smallgrp sophus tomlib transgrp uuid zeromqinterface"
ARG BUILD_PKGS="g++ gcc libc6-dev make autoconf libtool libgmp-dev libreadline-dev zlib1g-dev libzmq3-dev"
COPY --chown=gap:gap --chmod=755 download-gap-packages.py $PREFIX/bin
RUN apt-get -y install wget\
 && apt-get install -y $BUILD_PKGS libzmq5\
 && cd $PREFIX\
 && wget ${GAP_URL}\
 && apt-get -y remove --purge wget\
 && tar zxf gap-${GAP_VER}-core.tar.gz\
 && rm gap-${GAP_VER}-core.tar.gz\
 && cd $GAP_HOME\
 && ./configure\
 && make -j\
 && ln -s $GAP_HOME/gap $PREFIX/bin\
 && test -d $GAP_HOME/pkg || mkdir $GAP_HOME/pkg\
 && cd $GAP_HOME/pkg\
 && apt-get -y install python3-requests\
 && python3 $PREFIX/bin/download-gap-packages.py\
 && apt-get -y remove --purge python3-requests\
 && MAKEFLAGS=-j ../bin/BuildPackages.sh --parallel\
 && source $JUPYTER_HOME/bin/activate\
 && cd $GAP_HOME/pkg/jupyterkernel\
 && pip install . \
 && ln -s $GAP_HOME/pkg/jupyterkernel/bin/jupyter-kernel-gap $PREFIX/bin\
 && apt-get -y install less\
 && printf "SetUserPreference( \"Pager\", \"less\" );\nSetUserPreference(\"PagerOptions\", [ \"-f\", \"-r\", \"-a\", \"-i\", \"-M\", \"-j2\" ] );" >> $GAP_HOME/gap.ini\
 && chown -R gap:gap $GAP_HOME \
 && apt-get -y remove --purge $BUILD_PKGS\
 && cd $GAP_HOME\
 && rm -rf build cnf extern hpcgap src tst\
 && apt-get -y autoremove --purge
 

# install the script
COPY --chown=gap:gap --chmod=755 jupyter.sh $PREFIX/bin

# make sure everything in /home/gap is accesible to everyone
USER root
RUN chmod ga+w -R /home/gap
USER gap

# start with /notebooks folder
WORKDIR $NB_HOME
EXPOSE 8000
CMD ["jupyter.sh"]
