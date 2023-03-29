FROM dart:2.18.6-sdk

WORKDIR /projbackend

ADD . /projbackend/
RUN dart pub get

RUN dart pub global activate conduit 4.1.6

EXPOSE 6200

ENTRYPOINT ["sh", "-c", "dart pub run conduit:conduit db generate && dart pub run conduit:conduit db upgrade && dart pub run conduit:conduit serve --port 6200"]