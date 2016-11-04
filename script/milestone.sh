#!/bin/sh
#
# Normally this is called as './milestone.sh'
# 
# milestone by soonsebii

OPENWRT_PATH="$PWD"

pushd() {
  cd "$@" > /dev/null
}

popd() {
  cd "$OPENWRT_PATH" > /dev/null
}

update_feeds() {
  if [ -z "$1" -o -z "$2" ]; then
    echo "...failed to update_feeds(): invalid parameter" && return 1
  fi

  if [ -d feeds/"$1" ]; then
    package="$1"
    dateline="$2"

    pushd "feeds/$package"

    branch=$(git branch | awk '{print $2}')
    commit=$(git rev-list -n 1 --before="$dateline" "$branch")
    echo "...update feeds...$package - $branch - $commit"
    $(git reset -q --hard "$commit")

    popd
  else
    echo "...failed to update_feeds(): no such as directory" && return 1
  fi
}

update_feeds  luci        2016-07-25
update_feeds  routing     2016-08-18
update_feeds  wrtnode     2016-04-19
update_feeds  packages    2016-08-29
update_feeds  telephony   2016-04-21
update_feeds  management  2016-06-04

echo "...install feeds..."
# to prevent the install issue of package.
if [ -d feeds/custom ]; then
  ./scripts/feeds install -a -p custom 
fi
./scripts/feeds install -a

echo "...make defconfig..."
make defconfig
