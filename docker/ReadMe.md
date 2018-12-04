# Building a Docker Image

Docker is a container system that you can start learning about at [Docker.com][readAboutDocker].

[readAboutDocker]: https://www.docker.com

The Makefile (`build/Makefile`) includes rules to build a docker image from the
runtime pkg-repository and some boilerplate in this **docker** subdirectory.

See `docker/home/visioneval/help` (a text file/shell script) for an explanation
of what the resulting image does and how to use it. The basic idea is that
you run the container, pointing its data mountpoint at user data and the container
will run the selected model on that data, place the model output in the user data
folder, then exit.  The use case for this image is to run some kind of script or
other process manager to spin up docker containers one after another in each of
the many scenario folders describing the model inputs.

The Makefile (in the **build** directory) and the Dockerfile (here) pretty much
describe the process, which entails setting up a Docker context in the built
installer folder (and using a .dockerignore file to skip things that won't be
used from that context, notably the very large Windows binary repository). Then
the Dockerfile drives the assembly of the pieces.

A multistage Docker build is used in order to be able to slough off the
products of building binary packages for all of VisionEval and its dependencies
and not have to store those in the runtime image.
