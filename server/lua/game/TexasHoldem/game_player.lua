require "game.TexasHoldem.CardSet"


local _Player = {
    --用户id
    id = -1,
    --昵称
    name = "",
    --1男2女，默认男
    sex  = 1,
    --头像
    icon = "",
    handCards = {},
    cards = {},
    action = -1, 
    cardType = nil
}

function _Player:new(_id, _name,_sex,_icon,_cards)
    local self = { }
    setmetatable(self, { __index = Player })
    self.id = _id
    self.name = _name
    self.sex = _sex
    self.icon = _icon
    self.handCards = _cards
    self.cards = {}
    self.cardType = nil
    return self
end


return _Player