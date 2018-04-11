#!/usr/bin/lua
--[[
	luci listvalue get value, using formvalue
--]]

require ("luci.http")

mode = SimpleForm("modeSwitch", nil, nil)
mode.reset = false
mode.submit = false

mode_list = mode:field(ListValue,"mode",translate("Mode Select"))
mode_list:value("3G",translate("3G Mode"))
mode_list:value("ethernet",translate("Ethernet Mode"))
mode_list:value("wifi_wifi",translate("Wifi-Wifi Mode"))

if luci.http.formvalue("cbi.submit") then
    local network_mode,mode_str,ret_status
    local mode_type = mode:formvalue("cbid.modeSwitch.1.mode")
    if mode_type then
	if mode_type == "ethernet" then
	    network_mode = "eth"
	    mode_str = string.format("sh %s %s &",mode_switch_sh,network_mode)
	    luci.sys.call(mode_str)

	    luci.http.redirect(luci.dispatcher.build_url("wifimanage"))
	elseif mode_type == "3G"  then
	    network_mode = "3g"
	    mode_str = string.format("sh %s %s &",mode_switch_sh,network_mode)
	    luci.sys.call(mode_str)

	    luci.http.redirect(luci.dispatcher.build_url("wifimanage"))
	elseif mode_type == "wifi_wifi"  then
	    luci.http.redirect(luci.dispatcher.build_url("wifimanage/wifi2wifi"))
	else
	    luci.http.redirect(luci.dispatcher.build_url("wifimanage"))
	end
    end
end
