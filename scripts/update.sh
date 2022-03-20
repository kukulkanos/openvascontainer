#!/bin/bash
su greenbone -c "greenbone-feed-sync --type GVMD_DATA"; sleep 120 ; su greenbone -c greenbone-scapdata-sync; sleep 30; su greenbone -c greenbone-certdata-sync; sleep 30; su greenbone -c greenbone-nvt-sync
clear
echo "YOU SHOULD RELOAD YOUR CONTAINER"
