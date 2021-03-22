ARG GRADLE_VERSION='6.3'
ARG CLI_VERION=1.9.0
ARG GIT_TAG=v${CLI_VERION}}

FROM gradle:${GRADLE_VERSION}-jdk8 as build

RUN set -ex \
    ; git clone https://github.com/structurizr/cli.git /cli \
    ; cd /cli \
    ; git checkout ${GIT_TAG}

WORKDIR /cli
USER root

ARG GRADLE_BUILD_COMMAND="bootJar"
RUN gradle test --no-daemon --console plain
RUN gradle ${GRADLE_BUILD_COMMAND} --refresh-dependencies --no-daemon --console plain
RUN find . -name '*.jar'

FROM openjdk:8-jre-alpine as run
ARG CLI_VERION
ENV CLI_VERION=${CLI_VERION}

WORKDIR /
COPY --from=build /cli/build/libs/structurizr-cli-${CLI_VERION}.jar /cli/lib/structurizr-dsl-1.0.0.jar ./
RUN mkdir -p /workdir
WORKDIR /workdir

ENTRYPOINT java -jar /structurizr-cli-${CLI_VERION}.jar

