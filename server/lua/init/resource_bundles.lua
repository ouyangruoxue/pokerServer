--[[
-- 系统资源初始化文件
-- 初始化包括国际化资源等关键信息
--]]


local mutilanguage=require "init.international.multi_languages"


local _M={};
-- 默认语言资源,约定为英语
local default_languge='en';
-- 约定国际化资源初始化
--[[
-- 将 通过国家语言的标签来获取对应的资源信息,如果没有查找到相关语言的资源束,返回默认资源束的信息
-- example
    local bundles=require "init.resource_bundles"
    zh_bundles=bundles.getLanguageBundle('zh');
       
-- @param lang 语言标签的字符串,比如zh_cn 中文简体,en 英文
--]]
function _M.getLanguageBundle(lang)
	local langbundle=mutilanguage[lang];
	if(langbundle)then
		return mutilanguage[lang];
	end
	return mutilanguage[default_languge];
end

return _M