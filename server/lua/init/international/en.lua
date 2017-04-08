
local _M={};
local path='init.international.en'
local bundle_list={
	"user_msg","goods_msg","db_msg"
}

local lent = table.getn(bundle_list)
for i=1,lent,1 do 
	local msg = require (path..'.'..bundle_list[i]);
	table.merge(_M,msg)
end

return _M