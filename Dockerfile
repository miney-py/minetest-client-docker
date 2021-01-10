FROM alpine:latest AS compile

ENV MINETEST_VERSION 5.3.0
ENV MINETEST_GAME_VERSION stable-5


WORKDIR /usr/src/minetest

RUN apk add --no-cache git build-base irrlicht-dev cmake bzip2-dev libpng-dev \
		jpeg-dev libxxf86vm-dev mesa-dev sqlite-dev libogg-dev \
		libvorbis-dev openal-soft-dev curl-dev freetype-dev zlib-dev \
		gmp-dev jsoncpp-dev postgresql-dev luajit-dev ca-certificates && \
	git clone --depth=1 --single-branch --branch ${MINETEST_VERSION} -c advice.detachedHead=false https://github.com/minetest/minetest.git . && \
	git clone --depth=1 -b ${MINETEST_GAME_VERSION} https://github.com/minetest/minetest_game.git ./games/minetest_game && \
	rm -fr ./games/minetest_game/.git

RUN cd build && \
	cmake .. \
		-DCMAKE_INSTALL_PREFIX=/usr/local \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_CLIENT=TRUE \
		-DBUILD_UNITTESTS=FALSE \
		-DENABLE_SOUND=OFF \
		-DENABLE_POSTGRESQL=OFF \
		-DENABLE_REDIS=OFF \
		-DVERSION_EXTRA=miney_docker_client && \
	make && \
	make install

FROM utensils/opengl:stable AS server

COPY --from=compile /usr/local/share/minetest /usr/local/share/minetest
COPY --from=compile /usr/local/bin/minetest /usr/local/bin/minetest
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk add --no-cache sqlite-libs curl gmp libstdc++ libgcc luajit irrlicht x11vnc bash xdotool && \
	adduser -D minetest --uid 30000 -h /var/lib/minetest && \
	mkdir /var/lib/minetest/.minetest && \
	chown -R minetest:minetest /var/lib/minetest && \
	chmod 755 /usr/local/bin/entrypoint.sh


WORKDIR /var/lib/minetest

COPY --chown=minetest:minetest minetest.conf /var/lib/minetest/.minetest/minetest.conf

USER minetest:minetest

ENV \
    SERVER="minetest_server" \
    PASSWORD="" \
    PORT="30000" \
    PLAYERNAME="random" \
    RANDOM_INPUT="0" \
    VNC="0"

EXPOSE 5900/tcp

CMD ["/usr/local/bin/entrypoint.sh"]