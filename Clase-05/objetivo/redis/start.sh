#!/bin/bash
service ssh start 2>/dev/null
exec redis-server /etc/redis/redis.conf
