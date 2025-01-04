#!/bin/bash

##
## Correct way to benchmark a drive
##
## Blame: helmut.doring@slug.org
##

mountpoint='/root/mount'

# Just some decoration
baton() {
  spin='-\|/'
  i=0
  while kill -0 "$1" 2>/dev/null
    do
      i=$(( (i+1) %4 ))
      printf "\r${spin:$i:1}"
      sleep .1 
    done
}

# Necessary to avoid collisions
tmpdir=`mktemp -d`
mkdir -v -p -- "$mountpoint$tmpdir"
tmpfile=`mktemp --tmpdir=$tmpdir`
echo '--'

echo "WRITE data to $tmpfile:"
dd conv=fsync if=/dev/zero of="$tmpfile" bs=1M count=1024
echo '--'

echo "COPY $tmpfile to $mountpoint:"
dd conv=fsync if=$tmpfile of="$mountpoint$tmpfile" &
baton $!
echo '--'

# Trick for draining cached data
echo 1 >/proc/sys/vm/drop_caches
echo "READ 1GB testfile from mounted drive:"
dd if="$mountpoint$tmpfile" of=/dev/null &
baton $!
echo '--'

echo 'Cleaning up:'
rm -r -f -v -- "$tmpdir" "$mountpoint$tmpdir"
