FROM quay.io/aptible/alpine:3.4

RUN apk-install nginx

ENV SIMPLE_LE_REF 3a103b76f933f9aef782a47401dd2eff5057a6f7
ENV SIMPLE_LE_DIR /app/simp_le

RUN BUILD_DEPS="build-base openssl-dev libffi-dev python-dev git py-virtualenv py-pip" \
 && RUN_DEPS="ca-certificates libssl1.0 libcrypto1.0 libffi python" \
 && apk-install $BUILD_DEPS $RUN_DEPS \
 && mkdir -p "$SIMPLE_LE_DIR" \
 && git clone https://github.com/kuba/simp_le.git "$SIMPLE_LE_DIR" \
 && cd "$SIMPLE_LE_DIR" \
 && git checkout "$SIMPLE_LE_REF" \
 && ./venv.sh \
 && apk del $BUILD_DEPS \
 && rm -r "$HOME/.cache/pip/"

ENV PATH $SIMPLE_LE_DIR/venv/bin:$PATH
ADD bin/acme-acquire-cert $SIMPLE_LE_DIR/venv/bin/

ENV ACME_DIR /acme
RUN mkdir -p "$ACME_DIR" && chown nginx:nginx "$ACME_DIR"
ADD etc/nginx.conf /etc/nginx/nginx.conf

# Tests are added in the Dockerfile, but since they bundle a lot of
# dependencies, they run via test.sh instead.
ADD test /tmp/test

EXPOSE 80
CMD ["nginx"]
