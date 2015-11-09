#!/bin/bash
# vim: ft=bash


# Source/Docs: github.com/max675/raspicam-streamer
# (c) 2015 by max675

#raspivid -n -w 1280 -h 720 -b 4500000 -fps 30 -vf -hf -t 0 -o - | \
# cvlc -vvv stream:///dev/stdin --sout '#rtp{sdp=rtsp://:9000/}' :demux=h264

# 1sek
#raspivid -w 1920 -h 1080 -b 4500000 -fps 30 -vf -hf -t 0 -o - | cvlc -vvv 'stream:///dev/stdin' --sout '#rtp{sdp=rtsp://:9000/,caching=50}' :demux=h264 --live-caching=5 --sout-mux-caching=5 --sout-rtp-caching=5 --file-caching=5 --live-caching=5 --disc-caching=5 --network-caching=5 --cr-average=5


# -w 960 -h 540 \
raspivid \
 -w 1920 -h 1080 \
 -b 4500000  \
 -fps 30  -g 8 \
 -vf -hf -t 0 -o - | \
 cvlc -vvv \
 'stream:///dev/stdin' \
 --sout '#rtp{sdp=rtsp://:9000/,caching=50}' :demux=h264 \
 --live-caching=150 \
 --sout-mux-caching=0 \
 --sout-rtp-caching=0 \
 --file-caching=0 \
 --live-caching=0 \
 --disc-caching=0 \
 --network-caching=0 \
 --cr-average=0
