#!/bin/sh

cd ~/downloads/

echo "Checking for torrents..."

for f in *rutracker*.torrent;
do
  if [ -f $f ];
  then
    echo "Adding: ${f}"

    transmission-remote -a "${f}"

    if [ $? -eq 0 ];
    then
      echo "Success! Archiving: ${f}"

      mv "${f}" rutracker-archive
      # TODO: compress, etc.
    else
      echo "Failed to add to transmission."
    fi

  fi
done


echo "Done!"

