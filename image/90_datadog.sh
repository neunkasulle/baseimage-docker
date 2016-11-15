#!/bin/bash
set -e
if [[ $DATADOG_API_KEY ]]; then
  sed "s/api_key:.*/api_key: ${DATADOG_API_KEY}/" /etc/dd-agent/datadog.conf.example > /etc/dd-agent/datadog.conf

  mkdir -p /etc/service/datadog-agent/
  ln -s /opt/datadog-agent/runit /etc/service/datadog-agent/run

  if [[ $DATADOG_TAGS ]]; then
    sed -i -e "s/^#tags:.*$/tags: ${DATADOG_TAGS}/" /etc/dd-agent/datadog.conf
  fi
fi
