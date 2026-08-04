Content-Type: multipart/mixed; boundary="==FORTIGATE=="
MIME-Version: 1.0

--==FORTIGATE==
Content-Type: text/plain; charset="us-ascii"

config system global
    set hostname "${hostname}"
    set admintimeout 480
    set admin-sport 443
    set timezone 04
end

config system admin
    edit "admin"
        set password "${admin_password}"
    next
end

config system interface
    edit "port1"
        set mode static
        set ip ${port1_ip} ${port1_mask}
        set allowaccess ping https ssh fgfm
        set description "external"
        set mtu-override enable
        set mtu 9001
    next
    edit "port2"
        set mode static
        set ip ${port2_ip} ${port2_mask}
        set allowaccess ping https ssh fgfm probe-response
        set description "internal-gwlb"
        set mtu-override enable
        set mtu 9001
    next
    edit "port3"
        set mode static
        set ip ${port3_ip} ${port3_mask}
        set allowaccess ping
        set description "session-sync"
    next
    edit "port4"
        set mode static
        set ip ${port4_ip} ${port4_mask}
        set allowaccess ping https ssh fgfm
        set description "mgmt"
        set dedicated-to management
        set defaultgw ${port4_gw}
    next
end

config system probe-response
    set http-probe-value "OK"
    set mode http-probe
    set port 8008
end

config system ha
    set password "${ha_password}"
    set hbdev port3 50
    set override enable
    set session-pickup enable
    set session-pickup-connectionless enable
    set session-pickup-nat enable
    set standalone-config-sync enable
    set unicast-status enable
    set unicast-gateway ${port3_gw}
    config unicast-peers
        edit 1
            set peer-ip ${peer_ip}
        next
    end
end

config system standalone-cluster
    set standalone-group-id 1
    set group-member-id 1
    set layer2-connection unavailable
    set session-sync-dev port3
    config cluster-peer
        edit 1
            set peerip ${peer_ip}
            set syncvd root
            set peervd root
        next
    end
end

config system vdom-exception
    edit 1
        set object router.static
    next
    edit 2
        set object system.interface
    next
    edit 4
        set object system.standalone-cluster
    next
end

config router static
    edit 1
        set gateway ${port1_gw}
        set device "port1"
    next
    edit 2
        set dst 10.0.0.0 255.0.0.0
        set gateway ${port2_gw}
        set device "port2"
    next
    edit 3
        set gateway ${port4_gw}
        set device "port4"
        set priority 10
        set comment "mgmt-default-route"
    next
    edit 4
        set dst ${peer_ip} 255.255.255.255
        set gateway ${port3_gw}
        set device "port3"
        set comment "HA-peer-route"
    next
end

config firewall policy
    edit 1
        set name "allow-all"
        set srcintf "any"
        set dstintf "any"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
end
%{ if fortiflex_sn != "" ~}

execute vm-license ${fortiflex_sn}
execute reboot
%{ endif ~}

--==FORTIGATE==--
