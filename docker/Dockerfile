FROM rocker/r-ver

COPY /home/ /home/
COPY /pkg-repository/src /home/visioneval/pkg-repository/src

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    zlib1g-dev \
    libpng-dev \
    libtool

WORKDIR /home/visioneval
RUN install2.r \
    -r "file:pkg-repository" \
    -l "ve-lib" \
    -d FALSE \
    $(Rscript -e "as.character(available.packages(repos='file:pkg-repository',type='source')[,'Package'])")

RUN rm -f /home/visioneval/pkg-repository

CMD ["bash"]
