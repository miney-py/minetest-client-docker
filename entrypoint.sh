#!/bin/bash

export DISPLAY=:1

rm -f /tmp/.X1-lock

# Start Xvfb
echo "Starting Xvfb"
Xvfb $DISPLAY -ac -screen 0 800x600x16 &
xvfb_pid=$!

# prevent spikes if you spawn many containers simultaneously
sleep $((2 + $RANDOM % 6))

x11vnc_pid=0
if [ "$VNC" == "1" ]
then
  x11vnc -display $DISPLAY -bg -forever -nopw -quiet -xkb -rfbport 5901 &
  x11vnc_pid=$!
fi

if [ "${PLAYERNAME,,}" == "random" ]
then
  PLAYERNAME=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)
fi

if [ "$RANDOM_INPUT" == "1" ]
then
  minetest --address "$SERVER" --port "$PORT" --name "$PLAYERNAME" --password "$PASSWORD" --go --random-input &
else
  minetest --address "$SERVER" --port "$PORT" --name "$PLAYERNAME" --password "$PASSWORD" --go &
fi
minetest_pid=$!

function finish {
  kill -n 2 $minetest_pid & wait
  kill -n 2 $x11vnc_pid & wait
  kill -n 2 $xvfb_pid & wait
}
trap finish EXIT

# Workaround to revive died players
while :
do
   sleep 10
   xdotool key --delay 100 KP_Enter
done

