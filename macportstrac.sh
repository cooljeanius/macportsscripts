#!/bin/bash
# TODO: remember where this came from

if [ $# -lt 2 ]; then
  echo "Usage:"
  echo "macportstrac.sh query 'port name'"
  echo "macportstrac.sh viewticket 'ticket number'"
  exit
fi

INPUT=($@)
unset INPUT[0]

if [ $1 == "query" ]; then
  for PORT in ${INPUT[*]}; do
    echo "Port: ${PORT}"
    curl -s "http://trac.macports.org/query?status=!closed&port=~${PORT}" | grep ' assigned\| closed\| new\| reopened\|href.*/ticket/' | sed -e 's|<[^>]*>||g'
  done
fi

if [ $1 == "viewticket" ]; then
  for TICKET in ${INPUT[*]}; do
    echo "Ticket: #${TICKET}"
    open "http://trac.macports.org/ticket/${TICKET}"
  done
fi
