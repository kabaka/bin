#!/bin/bash

FILENAME="/home/kabaka/images/timelapse/timelapse_`date +%m%d%Y_%H%M%S%N`.jpeg"

streamer -q -o now.ppm 2> /dev/null && convert now.ppm $FILENAME && rm now.ppm

