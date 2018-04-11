require "string"
require "luci.sys"
require "luci.http"

mode_switch_sh="/etc/mode_switch.sh"
mode_query_filename="/www/net_status.txt"

network_mode_status = {}

mode=SimpleForm("modeSwitch",nil,nil)
mode.reset = false
mode.submit = translate("Mode Switch")

function network_mode_query(filename)
	local fdr=io.open(filename,"r")
	if fdr then
		for line in fdr:lines() do
			for index,value in string.gmatch(line,"(%w+):(.+)")  do
				value=string.gsub(value,"\n","")
				if index == "network"  then
					network_mode_status[index]=value
				end
			end
		end
		fdr:close()
	end

	if network_mode_status["network"] and network_mode_status["network"] == "ethernet"  then
		mode:field(DummyValue,"network_status",translate("Status:Ethernet Mode"))
	elseif network_mode_status["network"] and  network_mode_status["network"] == "3G" then
		mode:field(DummyValue,"network_status",translate("Status:3G Mode"))
	elseif  network_mode_status["network"] and  network_mode_status["network"]== "wifi-wifi"  then
		mode:field(DummyValue,"network_status",translate("Status:Wifi-Wifi Mode"))
	else
		mode:field(DummyValue,"network_status",translate("Status:Unkown Mode"))
	end
end


network_mode_query(mode_query_filename)

mode_list=mode:field(ListValue,"mode",translate("Mode Select"))
mode_list:value("3G",translate("3G Mode"))
mode_list:value("ethernet",translate("Ethernet Mode"))
mode_list:value("wifi_wifi",translate("Wifi-Wifi Mode"))

if luci.http.formvalue("cbi.submit")  then
	local network_mode,mode_str,ret_status
	local mode_type=mode:formvalue("cbid.modeSwitch.1.mode")
	if mode_type then
		if mode_type == "ethernet"  then
			network_mode="eth"
			mode_str=string.format("sh %s %s &",mode_switch_sh,network_mode)
			luci.sys.call(mode_str)

			luci.http.redirect(luci.dispatcher.build_url("wifimanage"))
		elseif mode_type == "3G"  then
			network_mode="3g"
			mode_str=string.format("sh %s %s &",mode_switch_sh,network_mode)
			luci.sys.call(mode_str)

			luci.http.redirect(luci.dispatcher.build_url("wifimanage"))
		elseif mode_type == "wifi_wifi"  then
			luci.http.redirect(luci.dispatcher.build_url("wifimanage/wifi2wifi"))
		else
			luci.http.redirect(luci.dispatcher.build_url("wifimanage"))
		end
	end
end


return mode
