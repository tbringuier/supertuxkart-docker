#!/bin/sh
set -eu

CONFIG=/data/server_config.xml

mkdir -p /data/addons /data/.local/share/supertuxkart
[ -e /data/.local/share/supertuxkart/addons ] || ln -s /data/addons /data/.local/share/supertuxkart/addons

esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/"/\&quot;/g'; }

if [ ! -f "$CONFIG" ]; then
    if [ "${STK_OWNER_LESS:-false}" = "true" ]; then configurable=false; else configurable=true; fi
    cat > "$CONFIG" <<XML
<?xml version="1.0"?>
<server-config version="6" >
  <server-name value="$(esc "${STK_SERVER_NAME:-SuperTuxKart Server}")" />
  <server-port value="${STK_PORT:-2759}" />
  <private-server-password value="$(esc "${STK_PASSWORD:-}")" />
  <motd value="$(esc "${STK_MOTD:-}")" />
  <server-mode value="${STK_GAME_MODE:-3}" />
  <server-difficulty value="${STK_DIFFICULTY:-1}" />
  <server-max-players value="${STK_MAX_PLAYERS:-8}" />
  <owner-less value="${STK_OWNER_LESS:-false}" />
  <server-configurable value="$configurable" />
  <firewalled-server value="false" />
</server-config>
XML
fi

if [ -n "${STK_ONLINE_USERNAME:-}" ]; then
    supertuxkart --init-user --login="$STK_ONLINE_USERNAME" --password="${STK_ONLINE_PASSWORD:-}"
fi

if [ "${STK_MODE:-lan}" = "wan" ]; then
    set -- "--wan-server=${STK_SERVER_NAME:-SuperTuxKart Server}"
else
    set -- "--lan-server=${STK_SERVER_NAME:-SuperTuxKart Server}"
fi
# The admin console reads stdin, so only enable it when a terminal is attached
if [ -t 0 ]; then set -- "$@" --network-console; fi

exec supertuxkart --server-config="$CONFIG" "$@"
