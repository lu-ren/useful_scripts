#!/bin/bash

# One way sync script local <- remote
# Usage: ./oneway_sync.sh [hostname] [local_path] [remote_path]

hostname='you@hostname.com'
local_path='/Users/exampleUser/Desktop/testfolder'
remote_path='/workplace/exampleUser/testfolder'
remote_command="inotifywait -r -e modify,attrib,close_write,move,create,delete $remote_path"
kill_command="pkill -f inotify"

if [ "$1" != "" ]
then
    hostname=$1
fi

if [ "$2" != "" ]
then
    local_path=$2
fi

if [ "$3" != "" ]
then
    remote_path=$3
fi

echo "Syncing local path $local_path with remote path $remote_path at $hostname"

trap "echo 'Exiting, killing remote inotify'; ssh $hostname \"$kill_command\"; exit 1;" INT

while true;
do
    ssh $hostname "$remote_command"
    echo "Syncing files"
    rsync -avzh $hostname:$remote_path $local_path
done
