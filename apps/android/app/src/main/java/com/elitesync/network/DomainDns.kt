package com.elitesync.network

import okhttp3.Dns
import java.net.InetAddress
import java.net.UnknownHostException

object DomainDns : Dns {
    private const val DOMAIN = "slowdate.top"
    private const val FALLBACK_IP = "101.133.161.203"

    override fun lookup(hostname: String): List<InetAddress> {
        return try {
            Dns.SYSTEM.lookup(hostname)
        } catch (e: UnknownHostException) {
            if (hostname.equals(DOMAIN, ignoreCase = true)) {
                Dns.SYSTEM.lookup(FALLBACK_IP)
            } else {
                throw e
            }
        }
    }
}
