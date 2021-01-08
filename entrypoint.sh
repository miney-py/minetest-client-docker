#!/bin/bash

export DISPLAY=:1

# Start Xvfb
echo "Starting Xvfb"
Xvfb $DISPLAY -ac -screen 0 800x600x16 &

# prevent spikes if you spawn many containers simultaneously
sleep $((2 + $RANDOM % 22))

if [ "$VNC" == "1" ]
then
  x11vnc -display $DISPLAY -bg -forever -nopw -quiet -xkb -rfbport 5901 &
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

# Workaround to revive died players
while :
do
   sleep 10
   xdotool key --delay 100 KP_Enter
done

