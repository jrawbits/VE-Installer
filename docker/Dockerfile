# Build dependencies first (compiling everything)
# 
FROM rocker/r-ver as VE-dependencies

COPY /pkg-repository/src /home/visioneval/pkg-repository/src
COPY /pkg-repository/*.lst /home/visioneval/

WORKDIR /home/visioneval

# Don't need libit2 - packaged version is not recent enough;
# Can build it as part of the dependency (it's bundled)
RUN apt-get update && apt-get install -y \
	libcurl4-gnutls-dev \
	libssh2-1-dev \
    libssl-dev \
    zlib1g-dev \
    libpng-dev \
    libtool 

RUN mkdir /home/visioneval/ve-lib \
	&& install2.r \
    -r "file:pkg-repository" \
    -l "ve-lib" \
    $(cat dependencies.lst) \
	&& rm dependencies.lst

RUN install2.r \
    -r "file:pkg-repository" \
    -l "ve-lib" \
    $(cat visioneval.lst) \
	&& rm visioneval.lst

CMD ["/bin/bash"]

FROM rocker/r-ver as VisionEval

WORKDIR /home/visioneval

COPY /home/visioneval /home/visioneval
COPY --from=VE-dependencies /home/visioneval/ve-lib /home/visioneval/ve-lib

RUN chmod +x /home/visioneval/help /home/visioneval/entrypoint.sh

ENTRYPOINT ["/home/visioneval/entrypoint.sh"]
CMD ["help"]

