ARG GRADLE_VERSION='6.9'
ARG CLI_VERSION=1.11.0

FROM gradle:${GRADLE_VERSION}-jdk11 as build
ARG GRADLE_VERSION
ARG CLI_VERSION

RUN set -ex \
    ; git clone https://github.com/structurizr/cli.git /cli \
    ; cd /cli \
    ; git checkout v${CLI_VERSION}

WORKDIR /cli
USER root

ARG GRADLE_BUILD_COMMAND="bootJar"
RUN gradle test --no-daemon --console plain
RUN gradle ${GRADLE_BUILD_COMMAND} --refresh-dependencies --no-daemon --console plain
RUN echo $(find . -name '*.jar')

FROM adoptopenjdk:16-jre as run
ARG CLI_VERSION

WORKDIR /
COPY --from=build /cli/build/libs/structurizr-cli-${CLI_VERSION}.jar .
RUN ln -s /structurizr-cli-${CLI_VERSION}.jar /structurizr-cli.jar

ENTRYPOINT ["java", "-jar", "/structurizr-cli.jar" ]
