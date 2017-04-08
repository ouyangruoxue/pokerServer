
local _M={}
local default_language="en"
local path='init.international.'
local language_list={
	zh_cn="zh_cn",
	en="en",
}

for k,v in pairs(language_list) do
	_M[k] = require (path..v);
end

return _M;
