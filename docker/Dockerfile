FROM rocker/r-ver

COPY /home/ /home/
COPY /pkg-repository/src /home/visioneval/pkg-repository/src

WORKDIR /home/visioneval
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    zlib1g-dev \
    libpng-dev \
    libtool \
	&& install2.r \
    -r "file:pkg-repository" \
    -l "ve-lib" \
    $(Rscript -e "as.character(available.packages(repos='file:pkg-repository',type='source')[,'Package'])") \
	&& rm -rf /home/visioneval/pkg-repository

CMD ["bash"]
