require "string"
require "luci.sys"
require "luci.http"


remote = SimpleForm("remoteassis",nil,nil)
remote.submit=translate("Assistance")
remote.reset=false

id=remote:field(DummyValue,"idtext",translate(" "))

function get_remote_port()
	math.randomseed(os.time())
	remote_port=math.random(10000,20000)

	return remote_port
end

function id.cfgvalue(self,section)
	if remote_port then
		id_value=string.format("ID: %s",remote_port)
	else
		id_value="ID: "
	end
	return id_value
end


if luci.http.formvalue("cbi.submit")  then
	local cmd_str,remote_id,ssh_domain
	cmd_str=string.format("uci get servercfgfile.servercfgfile.sshport555")
	ssh_domain=luci.sys.exec(cmd_str)
	ssh_domain=string.gsub(ssh_domain,"\n","")
	remote_id=get_remote_port()
	luci.sys.call("killall ssh")
	luci.sys.call("/etc/init.d/dropbear start")
	cmd_str=string.format("ssh -i /root/.ssh/id_rsa  -f -N -R %s:localhost:22 suwq@%s",remote_id,ssh_domain)
	luci.sys.call(cmd_str)
end

return remote
