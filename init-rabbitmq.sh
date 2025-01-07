#!/bin/bash

( rabbitmqctl wait --timeout 60 $RABBITMQ_PID_FILE ; \
  users_to_create="common" ; \
  read -r -a users_to_create_arr <<< $users_to_create ; \
  rabbitmqctl add_vhost /test ; \
  rabbitmqctl add_vhost /development ; \

  rabbitmqctl set_permissions -p / root  ".*" ".*" ".*"
  rabbitmqctl set_permissions -p /test root  ".*" ".*" ".*"
  rabbitmqctl set_permissions -p /development root  ".*" ".*" ".*"

  for user_to_create in "${users_to_create_arr[@]}" ; do
    rabbitmqctl add_user $user_to_create complexpassword 2>/dev/null
    rabbitmqctl set_user_tags $user_to_create administrator
    rabbitmqctl set_permissions -p / $user_to_create  ".*" ".*" ".*"
    rabbitmqctl set_permissions -p /test $user_to_create  ".*" ".*" ".*"
    rabbitmqctl set_permissions -p /development $user_to_create  ".*" ".*" ".*"
  done ; \

) &

# $@ is used to pass arguments to the rabbitmq-server command.
# For example if you use it like this: docker run -d rabbitmq arg1 arg2,
# it will be as you run in the container rabbitmq-server arg1 arg2
rabbitmq-server $@
