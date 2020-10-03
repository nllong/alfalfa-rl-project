FROM michaelwetter/ubuntu-1804_jmodelica_trunk

MAINTAINER Nicholas Long <nicholas.long@nrel.gov>
# This now pulls from mwetter's 18.04 Jmodelica since building JModelica no longer works since the source code
# has been removed from svn.jmodelica.org.

ENV ROOT_DIR /usr/local
USER developer

WORKDIR $HOME

RUN pip install --user flask-restful pandas
ENV PYTHONPATH $PYTHONPATH:$HOME
