ARG ELK_VERSION

## https://www.docker.elastic.co/
FROM docker.elastic.co/elasticsearch/elasticsearch:${ELK_VERSION}

## Adding our elasticsearch plugins setup here ...
RUN elasticsearch-plugin install analysis-icu
