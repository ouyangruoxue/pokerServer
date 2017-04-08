-- region *.lua
-- Date  2017-03-07
-- 此文件由[BabeLua]插件自动生成

local CardSet = { }

function CardSet:new()
    local carset = setmetatable({}, { __index = CardSet })
    return carset
end


-- function CardSet:insert(_cardId)
--    table.insert(self, _cardId)
-- end

function card_comp(card1, card2)
    if card1.cardId  ~= card2.cardId then 
        return card1.cardId > card2.cardId;
    else
        return card1.cardSuit > card2.cardSuit;
    end
end

function CardSet:insert(_card)
    table.insert(self, _card)

    -- 排序：最小的在前，大的在后（不判断花色）
    local size = table.getn(self)
  
    table.sort(self, card_comp);

--    local cardTemp = {}
--    for i=1, size-1, 1 do
--        for j=1, size-i, 1 do
--            if self[j].id > self[j+1].id then
--                cardTemp = self[j]
--                self[j] = self[j+1]
--                self[j+1] = cardTemp
--            end
--        end
--    end 
end


return CardSet

-- endregion
