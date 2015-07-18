#!/usr/bin/env sh

cd ~/var/downloads/firefox/

echo "Checking for torrents..."

for f in *.torrent;
do
  if [ -f $f ];
  then
    echo "Adding: ${f}"

    transmission-remote -a "${f}"

    if [ $? -eq 0 ];
    then
      echo "Success! Archiving: ${f}"

      mkdir -p ~/var/downloads/torrents/archive/

      mv "${f}" ~/var/downloads/torrents/archive/
      # TODO: compress, etc.
    else
      echo "Failed to add to transmission."
    fi

  fi
done


echo "Done!"

