FROM ghcr.io/skywa04885/ommnia-system-api:development

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN apk add bash

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]