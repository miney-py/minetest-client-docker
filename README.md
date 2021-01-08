# Minetest Client in Docker

Simulate players on a minetest server. Besides loadtests this helps for automated testing.

The minetest.conf is optimized to run many clients, but cause of that it renders also very ugly. So if you need better image quality, thats the starting point. 
It's also possible to enable opengl, but it will be also rendered on the CPU.

**_All rendering is done without GPU, so you need a fast CPU with many cores, to simulate 15+ clients and keep the server usable without heavy lags._**

## A single client

Start a client that connects to minetestserver.com and does random input on this server.

```docker run -d -e SERVER="minetestserver.com" -e RANDOM_INPUT=1 miney/minetest-client```

## Spawn a server and many clients

`docker-compose.exe up -d --scale minetest_client=10`

This starts a minetest [server](https://github.com/miney-py/miney-docker) with [mineysocket](https://github.com/miney-py/mineysocket) mod.

Don't join them all at once, scale slowly up, cause joining clients uses cpu. 
After some seconds it gets getting much better, and you can join another bunch of clients.

Some results on my AMD Ryzen 7 3700X:

* 70 clients, max_lag 0.4 and ~90% CPU usage running. No issues at all.
* 90 clients, max_lag was at 3.3, client movement was stuttering.
* 100 clients, max_lag 6+, thats the limit with my CPU. Every action took 10+ seconds. My CPU was constant at ~99%.

## RAM usage

Every client needs around 120 MB RAM. **100 Clients == 12GB RAM.**

## Environment variables

| Variable      | Default value     | Description
| ---------     | --------------    | -------------
| SERVER        | minetest_server   | server to connect
| PORT          | 30000             | server port to connect
| PLAYERNAME    | random            | A name or random to generate a random name
| PASSWORD      | "" (empty)        | servers password
| RANDOM_INPUT  | 0                 | Set to 1 to enable random input.<br /> **WARNING: Random input can destroys your world! The clients will pick nodes, dig deep holes and will place nodes randomly**
| VNC           | 0                 | Set to 1 to enable a VNC server on port 5901 for debugging
