#!/usr/bin/env bash
cd ~
docker-compose exec opa /opa build --bundle --output /bundled_policies/archiefpunt.tar.gz ./policies/archiefpunt
cd -