FROM alpine:3.22 AS build
ARG STK_VERSION=1.5
ARG STK_SHA256=33cf8841e4ff4082d80b9248014295bbbea61d14683e86dff100e3ab8f7b27cb
RUN apk add --no-cache build-base cmake pkgconf curl curl-dev openssl-dev zlib-dev linux-headers
WORKDIR /src
RUN curl -fsSL -o stk.tgz "https://github.com/supertuxkart/stk-code/releases/download/${STK_VERSION}/SuperTuxKart-${STK_VERSION}-src.tar.gz" \
 && echo "${STK_SHA256}  stk.tgz" | sha256sum -c - \
 && tar -xzf stk.tgz --strip-components=1 && rm stk.tgz
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DSERVER_ONLY=ON -DCHECK_ASSETS=OFF -DUSE_SQLITE3=OFF -DUSE_DNS_C=ON \
 && cmake --build build -j"$(nproc)" \
 && strip build/bin/supertuxkart
# The server only reads meshes and XML files: images, sounds and fonts become empty files
# (STK only checks that they exist), replays, shaders and translations are removed.
RUN find data -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.bmp' -o -iname '*.tga' \
        -o -iname '*.xcf' -o -iname '*.ogg' -o -iname '*.ogv' -o -iname '*.wav' -o -iname '*.ttf' -o -iname '*.otf' \) \
        -exec truncate -s 0 {} + \
 && find data/replay data/shaders data/po -type f -delete

FROM alpine:3.22
RUN apk add --no-cache libstdc++ libgcc libcurl libssl3 libcrypto3 zlib ca-certificates \
 && adduser -D -u 10001 -h /data stk
COPY --from=build /src/build/bin/supertuxkart /usr/local/bin/supertuxkart
COPY --from=build /src/data /usr/local/share/supertuxkart/data
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint
USER stk
WORKDIR /data
EXPOSE 2759/udp
ENTRYPOINT ["entrypoint"]
