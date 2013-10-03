#!/bin/bash

FEED_URL="http://playdegex.blogspot.com/feeds/posts/default?max-results=9999"
rm -rf _posts
mkdir _posts
./blogspot_to_jekyll.rb "http://playdegex.blogspot.com/feeds/posts/default?max-results=9999"
ls -1 _posts | wc -l

# Verify that jekyll file URLs map to existing blogger URLs.
J=1
for I in $(ls -1 _posts/* | tac)
do
  
  #_posts/2013-09-08-eaux-vives-park-and-paddling-pool.html
  #echo "$J -  I is $I"
  BLOGGER=$( echo $I | sed 's/_posts\/\([0-9]*\)-\([0-9]*\)-[0-9]*-\(.*\)/http:\/\/playdegex.blogspot.com\/\1\/\2\/\3/')
  #echo "BLOGGER is $BLOGGER"
  wget -q  $BLOGGER -O $(mktemp)
  if [ $? != "0" ] ; then
     echo "Problem with $BLOGGER"
     exit
  fi 
  J=$(expr $J + 1)
done

