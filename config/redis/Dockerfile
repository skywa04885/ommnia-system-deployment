FROM redis:7.4.2-alpine

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN apk add envsubst bash

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]