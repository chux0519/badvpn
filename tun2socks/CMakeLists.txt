# add_executable(badvpn-tun2socks
#     tun2socks.c
#     SocksUdpGwClient.c
# )
# target_link_libraries(badvpn-tun2socks system flow tuntap lwip socksclient udpgw_client socks_udp_client)

# install(
#     TARGETS badvpn-tun2socks
#     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
# )

# install(
#     FILES badvpn-tun2socks.8
#     DESTINATION ${CMAKE_INSTALL_MANDIR}/man8
# )

set(TUN2SOCKS_SOURCES
   tun2socks.c
   SocksUdpGwClient.c
)
badvpn_add_library(tun2socks "system;flow;tuntap;lwip;socksclient;udpgw_client;socks_udp_client" "" "${TUN2SOCKS_SOURCES}")