#!/usr/bin/lua

function vianet_download(url,dest)
    local dl_cmd=string.format("wget -qO '%s' '%s'",(dest:gsub("'", "")),(url:gsub("'", "")))
    return os.execute(dl_cmd)
end

vianet_download("https://canaan.io/downloads/software/avalon841/mm/latest/MM841.mcs", "/tmp/mm.mcs")
