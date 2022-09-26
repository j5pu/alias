#!/usr/bin/env bash

# BBIN default testing images
#
export BBIN_IMAGES

declare -Ag BBIN_IMAGES=(
  ["3.10"]=python:3.10-alpine
  ["3.10-bullseye"]=python:3.10-bullseye # latest
  ["3.10-slim"]=python:3.10-slim
  ["debian-backports"]=debian:bullseye-backports
  ["debian-slim"]=debian:bullseye-slim
  ["kali"]=kalilinux/kali-rolling
  ["kali-bleeding"]=kalilinux/kali-bleeding-edge
  ["zsh"]=zshusers/zsh
)
for _bbin_image in alpine archlinux bash busybox centos debian fedora ubuntu; do
  BBIN_IMAGES["${_bbin_image}"]="${_bbin_image}"
done

unset _bbin_image
