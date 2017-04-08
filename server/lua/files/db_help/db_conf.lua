
--[[
-- 文件系统基础配置文件，主要用于系统文件管理模块，本地进行系统的文件上传，文件下载，以及其他文件处理

--]]
local _M={}
local xuniji_ip = "192.168.1.24";
_M.redis_master_main={
        host = xuniji_ip,
        port = 6379,
        --database = "ZengsuTestDB",
        user = "root",
        password = "Zhengsu@2014",
                max_packet_size = 1024 * 1024 
}
_M.mysql_db_master = {
        host = xuniji_ip,
        port = 3306,
        database = "files_db",
        user = "root",
        password = "Zhengsu@2014",
                max_packet_size = 1024 * 1024 
}

_M.redis_master_main_ali={
        host = "139.196.180.249",
        port = 6379,
        --database = "ZengsuTestDB",
        user = "root",
        password = "Zhengsu@2014",
                max_packet_size = 1024 * 1024 
}
_M.mysql_db_master_ali = {
        host = "139.196.180.249",
        port = 3306,
        database = "files_db",
        user = "root",
        password = "Zhengsu@2014",
                max_packet_size = 1024 * 1024 
}

return _M