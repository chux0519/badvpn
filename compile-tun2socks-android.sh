#!/bin/bash

export ANDROID_USE_SHARED_LIBC=OFF
export WORKING_DIRECTORY=$(pwd)/android

. ./universal-android-toolchain/toolchain.sh "$@"

SOURCE_DIR=$(pwd)

rm -rf build && mkdir build && cd build || exit

CFLAGS="${CFLAGS} -static -fPIC -std=gnu99"
INCLUDES=("-I${SOURCE_DIR}" "-I${SOURCE_DIR}/lwip/src/include/ipv4" "-I${SOURCE_DIR}/lwip/src/include/ipv6" "-I${SOURCE_DIR}/lwip/src/include" "-I${SOURCE_DIR}/lwip/custom")
DEFS=(-DBADVPN_THREADWORK_USE_PTHREAD -DBADVPN_LINUX -DBADVPN_BREACTOR_BADVPN -D_GNU_SOURCE)
DEFS+=(-DBADVPN_LITTLE_ENDIAN -DBADVPN_THREAD_SAFE=1)
DEFS+=(-DBADVPN_USE_SELFPIPE -DBADVPN_USE_POLL)
DEFS+=(-DNDEBUG -DANDROID)

SOURCES="
base/BLog_syslog.c
system/BReactor_badvpn.c
system/BSignal.c
system/BConnection_unix.c
system/BConnection_common.c
system/BTime.c
system/BUnixSignal.c
system/BNetwork.c
system/BDatagram_common.c
system/BDatagram_unix.c
flow/StreamRecvInterface.c
flow/PacketRecvInterface.c
flow/PacketPassInterface.c
flow/StreamPassInterface.c
flow/SinglePacketBuffer.c
flow/BufferWriter.c
flow/PacketBuffer.c
flow/PacketStreamSender.c
flow/PacketPassConnector.c
flow/PacketProtoFlow.c
flow/PacketPassFairQueue.c
flow/PacketProtoEncoder.c
flow/PacketProtoDecoder.c
socksclient/BSocksClient.c
tuntap/BTap.c
lwip/src/core/udp.c
lwip/src/core/memp.c
lwip/src/core/init.c
lwip/src/core/pbuf.c
lwip/src/core/tcp.c
lwip/src/core/tcp_out.c
lwip/src/core/sys.c
lwip/src/core/netif.c
lwip/src/core/def.c
lwip/src/core/mem.c
lwip/src/core/tcp_in.c
lwip/src/core/stats.c
lwip/src/core/ip.c
lwip/src/core/timeouts.c
lwip/src/core/inet_chksum.c
lwip/src/core/ipv4/icmp.c
lwip/src/core/ipv4/ip4.c
lwip/src/core/ipv4/ip4_addr.c
lwip/src/core/ipv4/ip4_frag.c
lwip/src/core/ipv6/ip6.c
lwip/src/core/ipv6/nd6.c
lwip/src/core/ipv6/icmp6.c
lwip/src/core/ipv6/ip6_addr.c
lwip/src/core/ipv6/ip6_frag.c
lwip/custom/sys.c
tun2socks/tun2socks.c
base/DebugObject.c
base/BLog.c
base/BPending.c
flowextra/PacketPassInactivityMonitor.c
tun2socks/SocksUdpGwClient.c
udpgw_client/UdpGwClient.c
socks_udp_client/SocksUdpClient.c
"

OBJS=()
for f in $SOURCES; do
  obj=${f//\//_}.o
  "${CC}" -c ${CFLAGS} "${INCLUDES[@]}" "${DEFS[@]}" "${SOURCE_DIR}/${f}" -o "${obj}"
  OBJS=("${OBJS[@]}" "${obj}")
done

$AR rcs "$OUTPUT_DIR/libtun2socks.a" "${OBJS[@]}"
$RANLIB "$OUTPUT_DIR/libtun2socks.a"

# I know this is ugly, but works!
PROJECTS_ANDROID_CPP_DIR=("$HOME/Develop/Projects/"{"universal-android-tun2socks","pegasocks-android"}"/app/src/main/cpp/prebuilt/")

for OUTPUT in "${PROJECTS_ANDROID_CPP_DIR[@]}"; do
  if [ -d "$OUTPUT" ]; then

    mkdir -p "$OUTPUT/include/tun2socks"
    mkdir -p "$OUTPUT/lib/$ABI"

    cp ../tun2socks/tun2socks.h "$OUTPUT/include/tun2socks"
    cp "$OUTPUT_DIR/libtun2socks.a" "$OUTPUT/lib/$ABI"
  fi
done
