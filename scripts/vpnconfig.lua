require "luci.sgi.vianet_lib"

vpnstats = {}
vpnstats[1] = {}


function vpnstatus_update()
	local vpndevice = "/sys/devices/virtual/net/tun0"
	local ret = luci.fs.isdirectory(vpndevice)
	if ret  then
		led_on()
		vpnstats[1].stat=translate("started")
		vpnstats[1].detail=translate("VPN work in start state")
	else
		led_flash()
		vpnstats[1].stat=translate("stop")
		vpnstats[1].detail=translate("VPN work in stop state")
	end
end


cfgform = SimpleForm("vpncfg",nil)
cfgform.reset = false
cfgform.submit = false
--[[cfgform.submit = "Back to login"]]--

statustab = cfgform:section(Table,vpnstats,translate("VPN status"))
stats = statustab:option(DummyValue,"stat",translate("Status"))
detail = statustab:option(DummyValue,"detail",translate("Detail information"))

btnbox = cfgform:field(Button,"btn")
btnbox.template = "cbi/vianetbtn"


if luci.http.formvalue("startbtn") then
	luci.sys.call("/etc/init.d/openvpn restart")
	for i=1,10 do
		vpnstatus_update()
		luci.sys.call("sleep 1")
	end
end

if luci.http.formvalue("stopbtn")  then
	luci.sys.call("/etc/init.d/openvpn stop")
	vpnstatus_update()
end

--[[
if luci.http.formvalue("cbi.submit") and (not luci.http.formvalue("startbtn"))
	and (not luci.http.formvalue("stopbtn"))	 then
	luci.sys.call("/etc/init.d/openvpn stop")
	vpnstatus_update()
	luci.http.redirect(luci.dispatcher.build_url("admin/network/vpnregister"))
end
]]--

	vpnstatus_update()
return cfgform

