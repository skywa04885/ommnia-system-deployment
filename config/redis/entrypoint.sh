#!/bin/bash

export REDIS_PASSWORD=$(cat $REDIS_PASSWORD_FILE)
envsubst < /usr/local/etc/redis/redis.conf.template > /usr/local/etc/redis/redis.conf
exec redis-server /usr/local/etc/redis/redis.conf
