# What is knockers?

knockers is a generator for netcat call-home scripts.  It's useful for making
sure you can get into lots of machines from a central server.

## When to use knockers

Say you have the following machines:

- archaeopteryx (home desktop running OS X)
- beastie (home tomato router)
- oblivion (home development box running Gentoo)
- tokyo (work machine running Gentoo)
- asaka (home machine running Minix)

You have the following server:

- manko (server running Gentoo)

You'd like to make sure you can always get a connection to all of your client
machines whenever you need one, even if they are behind firewalls.

With knockers, this is easy.  You can generate a series of netcat commands that
will connect a shell to your server.  By putting this in a cron job on each
machine that runs every minute, you will be guaranteed access to your machines.

## Usage

    ruby knockers.rb <key> [server]

The key is used to generate a sequence of ports that the client will connect to
(knock on) and the server will listen on.  Each character of the key will
generate one port number in the range 1024-65535.  Each machine should have its
own key (for example, the first three or four letters of the hostname).

For the machine archaeopteryx, I will use a key of "arc".  Here's how to get
knockers to generate the portknocking routine:

    $ ruby knockers.rb arc myserver.com

This produces the following output:

    nc -z myserver.com 32855 && nc -z myserver.com 21230 && nc myserver.com 21599 -c/bin/bash
    nc -z -l -p32855 && nc -z -l -p21230 && nc -l -p21599

The first command is the client's command; the second is the command you will
execute on the server to receive the client's connection.

Create a cron job on the client:

    * * * * * nc -z myserver.com 32855 && nc -z myserver.com 21230 && nc myserver.com 21599 -c/bin/bash

This command will run once a minute, but a connection will only be created when
you need it, with the following command (run on the server):

    $ nc -z -l -p32855 && nc -z -l -p21230 && nc -l -p21599

Simply keep knockers.rb on your server and use it to generate the appropriate
connection command when you need to access one of your clients.
