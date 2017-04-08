
local _M = {
    
     --用户id
    game_player_id = -1,
    --昵称
    name = "",
    --1男2女，默认男
    sex  = 1,
    --头像
    icon = "",
    --是否是庄家0否1是
    isBanker = 0,
    --手牌
    handCards = {},
    --组合最大牌
    cards = {},
    --牌局结果0输1赢
    game_result = 0, 
    --牌型
    cardType = nil,
    --是否是虚拟玩家
    is_virtual_player = nil
}
_M._VERSION = '0.01'            
local mt = { __index = _M }  


function _M:new(_id, _name,_sex,_icon,_cards,is_virtual_player)
    local  player = setmetatable({}, mt);
    player.game_player_id = _id
    player.name = _name
    player.sex = _sex
    player.icon = _icon
    player.handCards ={}
    player.cards = _cards
    player.is_virtual_player = is_virtual_player
    return player
end



return _M
