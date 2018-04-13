FROM debian:9 

LABEL authors="remi-andre.olsen@scilifelab.se" \
    description="Docker image containing all requirements for NGI-NeutronStar pipeline"

# Install container wide requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    perl \
    rsync \
    build-essential \
    gcc \
    cmake \
    ca-certificates \
    python \
    python-dev \
    bamtools \
    libbamtools-dev \
    libpython-stdlib \
    libjsoncpp1 \
    libboost-iostreams-dev \
    libsqlite3-dev \
    libboost-graph-dev \
    liblpsolve55-dev \
    zlib1g-dev \
    git \
    && rm -rf /var/lib/apt/lists/*  && apt-get clean

# Install pip
RUN wget -O /opt/get-pip.py https://bootstrap.pypa.io/get-pip.py \
    && python /opt/get-pip.py \
    && rm -rf /opt/get-pip.py 


# Install BUSCO v3
# Usage notes:
#   docker run -it -v /your_mnt/:/your_mnt/ remiolsen/ngi-neutronstar cp -r /root/augustus/config $PWD/augustus_config 
#   docker run -it -v /your_mnt/:/your_mnt/ remiolsen/ngi-neutronstar cp -r /root/busco/config/config.ini.default $PWD/busco_config/config.ini
    # Edit config.ini to output and tmp dirs to your bound folder (/your_mnt/ or wherever)
#   docker run -v /your_mnt/:/your_mnt/ remiolsen/ngi-neutronstar /bin/bash -c "export BUSCO_CONFIG_FILE=$PWD/busco_config/config.ini; export AUGUSTUS_CONFIG_PATH=$PWD/augustus_config; BUSCO.py --in ..."

# install augustus
RUN cd /opt && wget -O - http://bioinf.uni-greifswald.de/augustus/binaries/augustus.current.tar.gz | tar zx && \
 cd augustus/ && make && make install && chmod -R 755 /opt/augustus
RUN cp -r /opt/augustus/scripts/* /usr/bin/
ENV PATH="/opt/augustus/bin:$PATH"

# install hmmer
RUN cd /opt && wget -O - http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz | tar zx && \
 cd hmmer-3.1b2-linux-intel-x86_64/ && ./configure && make && make install
# install ncbi blast
RUN cd /opt && wget -O - https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.7.1+-x64-linux.tar.gz | tar zx  && \
 cp ncbi-blast*/bin/* /usr/bin/
# install busco
RUN cd /opt && git clone http://gitlab.com/ezlab/busco && cd busco && python setup.py install && \ 
    cp scripts/*.py /usr/bin && ln -s /usr/bin/run_BUSCO.py /usr/bin/BUSCO.py 

# Install Quast
RUN pip install quast

# Install MultiQC
RUN pip install git+https://github.com/ewels/MultiQC.git 

# Download and install Supernova (Note! this link will expire)
RUN cd /opt && \
    wget -O supernova-2.0.1.tar.gz "http://cf.10xgenomics.com/releases/assembly/supernova-2.0.1.tar.gz?Expires=1523654947&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cDovL2NmLjEweGdlbm9taWNzLmNvbS9yZWxlYXNlcy9hc3NlbWJseS9zdXBlcm5vdmEtMi4wLjEudGFyLmd6IiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTIzNjU0OTQ3fX19XX0_&Signature=QZDo6qfLb~Xdg7ePaKOkU7Cg3OwhGSFGjlxL3X4NKtntsl~-vCAo8fTAq2NdKYmI~2TV861RiJ1wZpv~SQ8j7Kno7nH6IQ1wEcTH22Qm~~COKPXU4KT6KEsUyyrZ-ORR~STNtPU5VxV2iMrkhYL5TfpGzY4LEzw3lgQNUMyzsb2n4pWziD--U3Rq0v8n4NDJ3grogU7EK9CsipvoqC4JxCGgitVp4D3TzQ6Z4hI6TCDd0fLfmiBTOKscXxGo51U7GgpOThQTrdajpQDp6w9oSvWbJJap01XGKIT8pZITrC-NG6cIkUDiZNqt~OJSYvoofAZ~74nNRsEJGjMil0kc4Q__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA" | \
    tar zx
ENV PATH="/opt/supernova-2.0.1:$PATH"
