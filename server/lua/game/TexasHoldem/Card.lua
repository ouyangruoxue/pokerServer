--region *.lua
--Date 2017-03-07
--此文件由[BabeLua]插件自动生成

local _M = {
	--卡牌花色
    cardSuit = 1,
    --牌id
    cardId = 1,
    --牌大小点数
    cardValue = 1
}

local mt = { __index = _M }  

function _M:new(_suit, _id)
    local card = setmetatable({}, mt)
    card.cardSuit = _suit
    card.cardId = _id
    card.cardValue = _id
    return card
end

return _M
--endregion
