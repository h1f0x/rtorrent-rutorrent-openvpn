#!/usr/bin/env bash

# OpenVPN
mkdir -p /config/vpn
if [ ! -f /config/vpn/client.conf ]; then
    cp -r /defaults/config/vpn/client.conf /config/vpn/client.conf
fi

if [ ! -f /config/vpn/vpn.auth ]; then
    cp -r /defaults/config/vpn/vpn.auth /config/vpn/vpn.auth
fi

# ruTorrent
mkdir -p /config/rutorrent
if [ ! -f /config/rutorrent/users/rtorrent/settings/uisettings.json ]; then
    cp -r /var/rutorrent/rutorrent/share/* /config/rutorrent/
fi


# rTorrent
rm -rf /config/rtorrent/session/rtorrent.lock

mkdir -p /output/incomplete
mkdir -p /output/complete
mkdir -p /config/rtorrent/session
mkdir -p /config/rtorrent/log
mkdir -p /config/rtorrent/watch
mkdir -p /config/rtorrent/watch/load
mkdir -p /config/rtorrent/watch/start

if [ ! -f /config/rtorrent/rtorrent.rc ]; then
    cp -r /defaults/config/rtorrent/rtorrent.rc /config/rtorrent/rtorrent.rc
fi

chmod -R 777 /config/rutorrent
