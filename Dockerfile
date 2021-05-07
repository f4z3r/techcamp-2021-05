# build image
FROM ubuntu:hirsute as builder

# set timezone for python install
ENV TZ=Europe/Zurich
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install dependencies
RUN apt-get update && apt-get install -y build-essential libssl-dev cmake git python3-dev ninja-build

# install emscripten
WORKDIR /opt/
RUN git clone https://github.com/emscripten-core/emsdk.git
WORKDIR /opt/emsdk
RUN ./emsdk install latest
RUN ./emsdk activate latest
ENV PATH="/opt/emsdk:/opt/emsdk/upstream/emscripten:/opt/emsdk/node/14.15.5_64bit/bin:$PATH"
ENV EMSDK=/opt/emsdk
ENV EM_CONFIG=/opt/emsdk/.emscripten
ENV EMSDK_NODE=/opt/emsdk/node/14.15.5_64bit/bin/node

# copy data
WORKDIR /app
COPY ./CMakeLists.txt ./CMakeLists.txt
COPY ./lib ./lib
COPY ./shader ./shader
COPY ./src ./src

# build
WORKDIR /app/build_emscripten
ENV CC=emcc
ENV CXX=em++
RUN cmake -G "Ninja" ..
RUN ninja

###############
# runtime image
FROM gcr.io/distroless/python3-debian10

WORKDIR /app
EXPOSE 8080

COPY ./assets/ ./

COPY --from=builder /app/build_emscripten .

ENTRYPOINT ["python"]
CMD ["-m", "http.server", "8080"]
