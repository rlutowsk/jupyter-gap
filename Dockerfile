# syntax=docker/dockerfile:1
FROM debian

# root directory for apps
ARG PREFIX=/usr/local
# make sure it exists
WORKDIR $PREFIX

SHELL ["/bin/bash", "-c"]
# deal with packages
RUN sed -i -e 's/deb\.debian\.org/ftp\.de\.debian\.org/' /etc/apt/sources.list.d/debian.sources ;\
    apt-get -y autoremove ;\
    apt-get update ;\
    apt-get install -y python3-minimal python3-venv g++ gcc libc6-dev make autoconf libtool libgmp-dev libreadline-dev zlib1g-dev libzmq3-dev wget ;\
    apt-get clean

# add local user
RUN groupadd -g 1111 gap && useradd -u 1234 -d /home/gap -m -s /bin/bash -g gap gap ;\
    chown -R gap:gap $PREFIX

# directory holding notebooks
ENV NB_HOME=/notebooks
RUN test -d $NB_HOME || mkdir $NB_HOME; chown -R gap:gap $NB_HOME

# from now on we are in user mode
USER gap

# jupyter install with venv
ENV JUPYTER_HOME=$PREFIX/jupyter
RUN python3 -m venv $JUPYTER_HOME;\
    source $JUPYTER_HOME/bin/activate ;\
    pip install notebook==6.5.7

# download gap and remove unnecessary packages (this is easier than downloading them)
ENV GAP_VER=4.14.0
ENV GAP_HOME=$PREFIX/gap-$GAP_VER
RUN cd $PREFIX ;\
    wget https://github.com/gap-system/gap/releases/download/v${GAP_VER}/gap-${GAP_VER}.tar.gz ; \
    tar zxf gap-${GAP_VER}.tar.gz ;\
    rm gap-${GAP_VER}.tar.gz ;\
    cd $GAP_HOME/pkg;\
    rm -r 4ti2interface ace aclib agt anupq atlasrep autodoc automata automgrp \
    browse cap caratinterface cddinterface circle classicpres cohomolo congruence corefreesub corelg \
    crime cryst crystcat cubefree curlinterface cvec datastructures deepthought design difsets \
    digraphs edim example examplesforhomalg ferret fining float format forms fplsa fr \
    francy fwtree gauss gaussforhomalg gbnp generalizedmorphismsforcap genss gradedmodules \
    gradedringforhomalg grape groupoids grpconst guarana guava hap hapcryst hecke homalg homalgtocas \
    idrel images intpic io_forhomalg itc jupyterviz kan kbmag liealgdb liepring liering \
    linearalgebraforcap lins localizeringforhomalg loops lpres majoranaalgebras mapclass matgrp \
    matricesforhomalg modisom modulepresentationsforcap modules monoidalcategories nconvex nilmat nock \
    normalizinterface nq numericalsgps openmath packagemanager patternclass permut polymaking \
    qdistrnd qpa quagroup radiroot rcwa rds recog repndecomp repsn \
    ringsforhomalg sco scscp semigroups sglppow sgpviz simpcomp singular sl2reps sla smallantimagmas \
    smallsemi sonata sotgrps spinsym standardff symbcompcc thelma toolsforhomalg toric \
    toricvarieties typeset ugaly unipot unitlib utils walrus wedderga wpe xgap xmod xmodalg yangbaxter

# compile gap
RUN cd $GAP_HOME && ./configure && make -j ;\
    ln -s $GAP_HOME/gap $PREFIX/bin ;\
    ln -s $GAP_HOME/gac $PREFIX/bin ;\
    cd $GAP_HOME/pkg ;\
    MAKEFLAGS=-j ../bin/BuildPackages.sh --parallel ;\
    source $JUPYTER_HOME/bin/activate && cd $GAP_HOME/pkg/jupyterkernel && pip install . ;\
    ln -s $GAP_HOME/pkg/jupyterkernel/bin/jupyter-kernel-gap $PREFIX/bin

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
