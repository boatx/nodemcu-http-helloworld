-- Init lua from nodemcu documentation https://nodemcu.readthedocs.io/en/latest/en/upload/#initlua
dofile("credentials.lua")
ip_addr = nil

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running")
        file.close("init.lua")
        dofile("httpserver.lua")
    end
end

wifi_connect_event = function(T)
    print("Connection to AP("..T.SSID..") established!")
    print("Waiting for IP address...")
    if disconnect_ct ~= nil then disconnect_ct = nil end
end

wifi_got_ip_event = function(T)
    print("Wifi connection is ready! IP address is: "..T.IP)
    print("Startup will resume momentarily, you have 3 seconds to abort.")
    print("Waiting...")
    ip_addr = T.IP
    tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
end

wifi_disconnect_event = function(T)
    if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
        return
    end
    local total_tries = 75
    print("\nWiFi connection to AP("..T.SSID..") has failed!")

    for key,val in pairs(wifi.eventmon.reason) do
        if val == T.reason then
            print("Disconnect reason: "..val.."("..key..")")
            break
        end
    end

    if disconnect_ct == nil then
        disconnect_ct = 1
    else
        disconnect_ct = disconnect_ct + 1
    end
    if disconnect_ct < total_tries then
        print("Retrying connection...(attempt "..(disconnect_ct+1).." of "..total_tries..")")
    else
        wifi.sta.disconnect()
        print("Aborting connection to AP!")
        disconnect_ct = nil
    end
end

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect_event)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)

print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=SSID, pwd=PASSWORD})
