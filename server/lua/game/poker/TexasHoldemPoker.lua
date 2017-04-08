--[[
-- 扑克牌的数据预定义
-- 提供扑克牌的生成,随机输出牌,
-- 同时修改该扑克牌的状态防止系统被攻击或者串改
]]--
local pokerDefault = require "game.poker.Poker"
local cjson = require "cjson"

local _TexasholdemPoker = {}
 
function _TexasholdemPoker.new()
    -- body
    --local resultTable = table.clone(pokerDefault);
    -- 由于数组为引用,所以对于系统中的值需要进行clone处理,特别对于
    local resultTable = setmetatable({}, pokerDefault);
    -- very import 
    resultTable.CardValues = table.clone(pokerDefault.CardValues);
    resultTable.CardValues.Ace = 14;
    return resultTable;
end
 
-- 比如poker牌的卡牌的有效值在德州扑克中ace > KING 所以将ace的值需要设定为14

-- local testTa =  _TexasholdemPoker.new();  
-- ngx.say(cjson.encode(testTa:new(1)).." "..cjson.encode(testTa.CardValues));
return _TexasholdemPoker.new();

 