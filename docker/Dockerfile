# Build dependencies first (compiling everything)
# 
FROM rocker/r-ver as VE-dependencies

COPY /ve-pkgs/src /home/visioneval/ve-pkgs/src
COPY /ve-pkgs/*.lst /home/visioneval/

WORKDIR /home/visioneval

RUN apt-get update && apt-get install -y \
	libcurl4-gnutls-dev \
	libssh2-1-dev \
  libssl-dev \
  zlib1g-dev \
  libpng-dev \
  libtool 

RUN mkdir /home/visioneval/ve-lib \
	&& install2.r \
    -r "file:ve-pkgs" \
    -l "ve-lib" \
    $(cat dependencies.lst) \
	&& rm dependencies.lst

RUN install2.r \
    -r "file:ve-pkgs" \
    -l "ve-lib" \
    $(cat visioneval.lst) \
	&& rm visioneval.lst

CMD ["/bin/bash"]

FROM rocker/r-ver as VisionEval

WORKDIR /home/visioneval

# The following for trying to get it all to work interactively:
RUN apt-get update && apt-get install -y vim-tiny

COPY /home/visioneval /home/visioneval
COPY --from=VE-dependencies /home/visioneval/ve-lib /home/visioneval/ve-lib

RUN chmod +x /home/visioneval/help /home/visioneval/entrypoint.sh

ENTRYPOINT ["/home/visioneval/entrypoint.sh"]
CMD ["help"]

