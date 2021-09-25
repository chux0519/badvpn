#!/bin/bash

. universal-android-toolchain/toolchain.sh "$@"

SRCDIR=$(pwd)

rm -rf build && mkdir build && cd build

CFLAGS="${CFLAGS} -fPIC -std=gnu99"
INCLUDES=("-I${SRCDIR}" "-I${SRCDIR}/lwip/src/include/ipv4" "-I${SRCDIR}/lwip/src/include/ipv6" "-I${SRCDIR}/lwip/src/include" "-I${SRCDIR}/lwip/custom")
DEFS=(-DBADVPN_THREAD_SAFE=0 -DBADVPN_LINUX -DBADVPN_BREACTOR_BADVPN -D_GNU_SOURCE -DBADVPN_USE_SIGNALFD -DBADVPN_USE_EPOLL -DBADVPN_LITTLE_ENDIAN -DANDROID)

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
    "${CC}" -c ${CFLAGS} "${INCLUDES[@]}" "${DEFS[@]}" "${SRCDIR}/${f}" -o "${obj}"
    OBJS=("${OBJS[@]}" "${obj}")
done

$AR rcs $OUTPUT_DIR/libbadvpn.a "${OBJS[@]}"
