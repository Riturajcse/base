#!/bin/bash -e

_copy_script_remote() {
  local user="$SSH_USER"
  local key="$SSH_PRIVATE_KEY"
  local port=22
  local host="$1"
  shift
  local script_name="$1"
  local script_path_local="$SCRIPTS_DIR/remote/$script_name"
  shift
  local script_dir_remote="$1"
  local script_path_remote="$script_dir_remote/$script_name"

  __process_msg "Copying $script_path_local to remote host: $script_path_remote"
  remove_key_cmd="ssh-keygen -q -f '$HOME/.ssh/known_hosts' -R $host"
  {
    eval $remove_key_cmd
  } || {
    true
  }

  _exec_remote_cmd $host "mkdir -p $script_dir_remote"
  copy_cmd="rsync -q -avz -e \
    'ssh -q \
      -o StrictHostKeyChecking=no \
      -o NumberOfPasswordPrompts=0 \
      -p $port \
      -i $SSH_PRIVATE_KEY \
      -C -c blowfish' \
      $script_path_local $user@$host:$script_path_remote"

  copy_cmd_out=$(eval $copy_cmd)
  echo "$script_path_remote"
}
