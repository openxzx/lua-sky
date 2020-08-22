require "string"
require "luci.sys"
require "luci.fs"
require "luci.http"

ssid_array = {}
ap_ssid = {}
recodes = {}


ssid_dir="/etc/ssid_list/"
mode_switch_sh="/etc/mode_switch.sh"
outputfilename="/tmp/iwlistlog.txt"

function ap_ssid_parse()
	ret=luci.sys.exec("uci get wireless.@wifi-iface[0].mode")
	if ret  then
		tmp_ssid=string.gsub(ret,"\n","")
	end

	if  tmp_ssid and tmp_ssid == "sta"  then
		ap_ssid[1]=luci.sys.exec("uci get wireless.@wifi-iface[0].ssid")
	else
		ret=luci.sys.exec("uci get wireless.@wifi-iface[1].mode")
		if ret  then
			tmp_ssid=string.gsub(ret,"\n","")
		end
		if tmp_ssid and tmp_ssid == "sta"  then
			ap_ssid[1]=luci.sys.exec("uci get wireless.@wifi-iface[1].ssid")

		else
			ap_ssid[1]=""
		end
	end

	ap_ssid[1]=string.gsub(ap_ssid[1],"\n","")
end

function ssid_scanning()
	local cmd_detect=luci.sys.exec("which iw")
	cmd_detect=string.gsub(cmd_detect,"\n","")
	if cmd_detect ~="" then
		local lan_name=luci.sys.exec("uci get network.lan.ifname")
		lan_name=string.gsub(lan_name,"\n","")
		local iw_cmd=string.format("iw dev %s scan |grep SSID |sort -r |uniq > /tmp/iwlistlog.txt",lan_name)
		luci.sys.call(iw_cmd)
	else
		luci.sys.exec("iwlist scanning |grep SSID |sort -r |uniq > /tmp/iwlistlog.txt")
	end
end

function ssid_parse(filename)
	local fdr=io.open(filename,"r")
	if fdr then
		for line in fdr:lines() do
			for index,value in string.gmatch(line,"(%w+):((.+))") do
				if value  then
					vv=string.gsub(value,"\"","")
				end
				if vv then
					local ssid_str=string.gsub(vv,"^%s*(.-)%s*$","%1")
					ssid:value(ssid_str,ssid_str)
				end
			end
		end
		fdr:close()
	end
end


wifistatus=SimpleForm("wifistatus",nil,nil)
wifistatus.submit=false
wifistatus.reset=false

cur_ssid=wifistatus:field(DummyValue,"tab",translate("Current Connect to:"))

function cur_ssid.cfgvalue()
	if ap_ssid[1] and ap_ssid[1] ~= "" then
		--sta_ssid = string.format("Current Connect to: %q",ap_ssid[1])
		sta_ssid = ap_ssid[1]
	else
		---sta_ssid = translate("Current Connect to: not connect")
		sta_ssid = translate("not connect")
	end

	return sta_ssid
end


del = SimpleForm("wifidel",nil,translate("Wifi Management"))
del.submit=false
del.reset=false

ssid=del:field(ListValue,"ssid",translate("SSID"))

combtn=del:field(Button,"wifibtn")
combtn.template="cbi/vianetwifibtn"

ap_ssid_parse()
if ap_ssid[1] ~= ""  then
	local conn_ssid=string.format("%s ----connected",ap_ssid[1])
	ssid:value(ap_ssid[1],conn_ssid)
end


ssid_scanning()
ssid_parse(outputfilename)

if luci.http.formvalue("subbtn")  and (not luci.http.formvalue("intbtn")) and (not luci.http.formvalue("listbtn"))  then
	local ssid=del:formvalue("cbid.wifidel.1.ssid")
	if ssid and ssid ~= nil then
		local str=string.format("echo %q > /tmp/test_log.txt",ssid)
		luci.sys.call(str)
		luci.http.redirect(luci.dispatcher.build_url("admin/status/wifimanage/conn"))
	else
		del.message=translate("Invalid ssid")
	end
end

if luci.http.formvalue("intbtn") and (not luci.http.formvalue("subbtn")) and (not luci.http.formvalue("listbtn")) then
	local virtual_ssid,mode,encr,key
	virtual_ssid="a"
	mode="wifi"
	encr="none"
	key="a"

	local exec_str=string.format("( sh '%s' '%s' '%s' '%s' '%s' & )",mode_switch_sh,mode,virtual_ssid,encr,key)
	luci.sys.call(exec_str)
end


if luci.http.formvalue("listbtn") and (not luci.http.formvalue("subbtn")) and (not luci.http.formvalue("intbtn")) then
	ssid_scanning()
	ssid_parse(outputfilename)
end
return wifistatus,del
