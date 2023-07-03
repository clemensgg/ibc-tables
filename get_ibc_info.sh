#!/bin/bash

# Fetch channels information
function get_channels {
  NODE=$1
  PAGE_KEY=""
  CHANNELS=""

  while true; do
    RESPONSE=$(curl -s --max-time 3 "${NODE}/ibc/core/channel/v1/channels?pagination.key=${PAGE_KEY}")
    if [[ -z "$RESPONSE" ]]; then
      exit 1
    fi
    CHANNELS_ARRAY=$(echo "${RESPONSE}" | jq -c '.channels[]')
    for CHANNEL in $CHANNELS_ARRAY; do
      CHANNELS+="${CHANNEL},"
    done
    PAGE_KEY=$(echo "${RESPONSE}" | jq -r '.pagination.next_key')
    if [ "${PAGE_KEY}" == "null" ]; then
      break
    fi
  done

  echo "[${CHANNELS%,}]"
}

# Fetch connections information
function get_connections {
  NODE=$1
  PAGE_KEY=""
  CONNECTIONS=""

  while true; do
    RESPONSE=$(curl -s --max-time 3 "${NODE}/ibc/core/connection/v1/connections?pagination.key=${PAGE_KEY}")
    if [[ -z "$RESPONSE" ]]; then
      exit 1
    fi
    CONNECTIONS_ARRAY=$(echo "${RESPONSE}" | jq -c '.connections[]')
    for CONNECTION in $CONNECTIONS_ARRAY; do
      CONNECTIONS+="${CONNECTION},"
    done
    PAGE_KEY=$(echo "${RESPONSE}" | jq -r '.pagination.next_key')
    if [ "${PAGE_KEY}" == "null" ]; then
      break
    fi
  done

  echo "[${CONNECTIONS%,}]"
}

# Print formatted info
function print_info {
  NODE=$1
  CHANNELS_JSON=$2
  CONNECTIONS_JSON=$3

  NUM_CHANNELS=$(echo "${CHANNELS_JSON}" | jq '. | length')
  CHAIN_ID=$(curl -s --max-time 3 "${NODE}/cosmos/base/tendermint/v1beta1/blocks/latest" | jq -r .block.header.chain_id)
  if [ $? -ne 0 ]; then
    exit 1
  fi
  echo "CHAIN_ID, CLIENT, CONNECTION, CHANNEL, PORT, COUNTERPARTY_CHAIN, COUNTERPARTY_CLIENT, COUNTERPARTY_CONNECTION, COUNTERPARTY_CHANNEL, COUNTERPARTY_PORT"
  for (( each_channel=0; each_channel < NUM_CHANNELS; each_channel++ ))
  do
    STATE=$(echo "${CHANNELS_JSON}" | jq -r ".[${each_channel}].state")
    if [ "$STATE" != "STATE_OPEN" ]; then
      continue
    fi
    COUNTERPARTY_PORT=$(echo "${CHANNELS_JSON}" | jq -r ".[${each_channel}].counterparty.port_id")
    COUNTERPARTY_CHANNEL=$(echo "${CHANNELS_JSON}" | jq -r ".[${each_channel}].counterparty.channel_id")
    PORT=$(echo "${CHANNELS_JSON}" | jq -r ".[${each_channel}].port_id")
    CHANNEL=$(echo "${CHANNELS_JSON}" | jq -r ".[${each_channel}].channel_id")
    CONNECTION=$(echo "${CHANNELS_JSON}" | jq -r ".[${each_channel}].connection_hops[0]")
    CONNECTION_JSON=$(echo "${CONNECTIONS_JSON}" | jq ".[] | select(.id == \"$CONNECTION\")")
    COUNTERPARTY_CONNECTION=$(echo "${CONNECTION_JSON}" | jq -r .counterparty.connection_id)
    COUNTERPARTY_CLIENT=$(echo "${CONNECTION_JSON}" | jq -r .counterparty.client_id)
    CLIENT=$(echo "${CONNECTION_JSON}" | jq -r .client_id)
    CLIENT_JSON=$(curl -s --max-time 3 "${NODE}/ibc/core/client/v1/client_states/${CLIENT}")
    if [ $? -ne 0 ]; then
      exit 1
    fi
    COUNTERPARTY_CHAIN=$(echo "${CLIENT_JSON}" | jq -r .client_state.chain_id)
    echo "${CHAIN_ID}, ${CLIENT}, ${CONNECTION}, ${CHANNEL}, ${PORT}, ${COUNTERPARTY_CHAIN}, ${COUNTERPARTY_CLIENT}, ${COUNTERPARTY_CONNECTION}, ${COUNTERPARTY_CHANNEL}, ${COUNTERPARTY_PORT}"
  done
}

function get_info {
  SECONDS=0
  NODE=$1
  CHANNELS_JSON=$(get_channels "${NODE}")
  CONNECTIONS_JSON=$(get_connections "${NODE}")
  
  if [[ -z "$CHANNELS_JSON" || -z "$CONNECTIONS_JSON" ]]; then
    exit 1
  fi

  print_info "${NODE}" "${CHANNELS_JSON}" "${CONNECTIONS_JSON}"
}

get_info $1
exit
