
local _M={}

_M.mysql_master = {
	host = "139.196.180.249",
        port = 3306,
        database = "poker",
        user = "root",
        password = "zhengsu@2014",
	max_packet_size = 1024 * 1024 
}


_M.redis_master_main={
        host = "127.0.0.1",
        port = 6379,
        --database = "ZengsuTestDB",
        user = "root",
        password = "Zhengsu@2014",
                max_packet_size = 1024 * 1024 
}

return _M