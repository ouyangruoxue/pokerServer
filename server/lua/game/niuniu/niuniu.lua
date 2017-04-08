--[[
-- 牛牛卡牌的玩法预定义
-- 定义卡牌组合的类型,卡牌的大小比较,以及赔率倍数等
-- 同时修改该扑克牌的状态防止系统被攻击或者串改
]]--

local Poker = require "game.poker.Poker"
local cjson = require "cjson"
local _NNPoker = {};

-- 牛牛的牌的大小定义
--[[
十小 > 炸弹 >  五花 > 四花 > 牛牛 > 有分 > 没分；
]]
_NNPoker.NNCardType = {
	LessTen = 14,	-- 10小
	Bomb = 13 ,   -- 炸弹
	FiveJinhua = 12, -- 五金花
	FourJinhua = 11, -- 银花
	Ten_Niu = 10, 
	Nine_Niu = 9,
	Eight_Niu = 8,
	Seven_Niu = 7,
	Six_Niu = 6,
	Five_Niu = 5,
	Four_Niu = 4,
	Three_Niu = 3,
	Tow_Niu = 2,
	One_Niu = 1,
	NoNiu = 0,		-- 没牛
}



_NNPoker.CardTypeDescription = 
{
    "普通牌,没有牛牌",
    "一牛", "二牛", "三牛", "四牛", "五牛", "六牛", "七牛", "八牛", "九牛","牛牛"
    ,"银花","金花","炸弹","10小" 
}


_NNPoker.NNCardTypeMap = {
"One_Niu", "Tow_Niu", "Three_Niu","Four_Niu","Five_Niu","Six_Niu","Seven_Niu","Eight_Niu","Nine_Niu",
}


local NNCardType = _NNPoker.NNCardType;
local NNCardTypeMap = _NNPoker.NNCardTypeMap;
--[[
	赔率定义
]]
_NNPoker.NNCardTypeOdds = {
	Bomb = 6 ,   -- 炸弹
	LessTen = 5,	-- 10小
	FiveJinhua = 5, -- 五金花
	FourJinhua = 4, 
	Nine_Niu = 2,
	Eight_Niu = 2,
	Seven_Niu = 2,
	Six_Niu = 1,
	Five_Niu = 1,
	Four_Niu = 1,
	Three_Niu = 1,
	Tow_Niu = 1,
	One_Niu = 1,
	NoNiu = 1,		-- 没牛
}


--[[
--	牛牛扑克炸弹,排序对比函数
card1 = {
	 cardCounts = 1,
}	 cards = {}
-- @param card1 一个包含相同数字的数量以及卡牌的数组的对象
-- @param card2 一个包含相同数字的数量以及卡牌的数组的对象 通过size进行排行
-- @return 返回当前卡牌的组合的最大类型
]]

function niuniu_comp(card1,card2)
	return card1.cardCounts > card2.cardCounts
end

function niuniu_removeOpt(card1,card2)
	 if card1.cardId == card2.cardId and card1.cardSuit == card2.cardSuit then
	 	-- 说明存在 则返回nil
	 	return nil;
	 end
	 return card1;
end

--[[
	返回所有3+2的牌,如果3 不为牛,则不需要不加入数组
	牌为5张
 
-- @param cards 用户5张卡牌的数组 扑克牌必须排序
-- @return 返回当前卡牌的组合的最大类型
]]
function  _NNPoker.C_M_3(srcTable)
    -- body
    local m = table.getn(srcTable);
    local n = 3;
    local index = 1;
    local tDes = {};
    local tDes2 = {};
    
    for index1 = 1, m-n+1 , 1 do
        for index2 = index1 + 1, m-1, 1 do
            for index3 = index2 + 1, m, 1 do 
                tDes[index] =  {
                   srcTable[index1],srcTable[index2],srcTable[index3]
                };  
                local arrayIndexs = {1,2,3,4,5} 
                arrayIndexs[index1] = nil;
                arrayIndexs[index2] = nil;
                arrayIndexs[index3] = nil;
                local tDes2Index = 1;

               	tDes2[index] = {};
                		 
                for i = 1,5,1 do
                	if arrayIndexs[i] then 
                		tDes2[index][tDes2Index] = srcTable[i];
                		tDes2Index = tDes2Index + 1;
                	end 
                end
                
                index = index + 1;
            end
        end
    end
    return tDes, tDes2;
end 

--[[
	计算牌的大小,返回最大组合的牛牌组合
	牌为5张
 
-- @param cards 用户5张卡牌的数组 扑克牌必须排序
-- @return 返回当前卡牌的组合的最大类型
]]

function _NNPoker.getCardsMaxType(cards)
	-- 首先删除卡牌中的10以上的卡牌
	local tenCards = 0; 
	local newCards = {};
	-- 牛牌记录
	local niuCards = {};
	local niuCardsIndex = 1;	-- 数组index
	-- 非牛牌记录
	local noniuCards = {}; 
	local noniuCardsIndex = 1;

	-- 花牌记录
	local huaCards = {}
	local huaCardsIndex = 1;

	-- 用于炸弹的判断记录
	local cardsNumb = {};
	local idTypes = 0;
	local lastId = nil;
	for i=1,5,1 do
		-- 判断炸弹的依赖
		local cardId = cards[i].cardId;
		  
		if not lastId or lastId ~=  cardId then 
			idTypes = idTypes + 1;
			cardsNumb[idTypes] = { cardCounts = 1};
			cardsNumb[idTypes].cards = {};
			cardsNumb[idTypes].cards[cardsNumb[idTypes].cardCounts] = cards[i];
			--ngx.say("---------------分割线----------------",idTypes," ",cardsNumb[idTypes].cardCounts);
		else   
			cardsNumb[idTypes].cardCounts = cardsNumb[idTypes].cardCounts + 1;
			cardsNumb[idTypes].cards[cardsNumb[idTypes].cardCounts] = cards[i];
			--ngx.say("---------------分割线----------------",idTypes," ",cardsNumb[idTypes].cardCounts);
		end
		if cards[i].cardId > 10 then 
			huaCards[huaCardsIndex] = cards[i];
			huaCardsIndex = huaCardsIndex + 1;
		end

		if cards[i].cardId > 9 then 
			niuCards[niuCardsIndex] = cards[i];
			niuCardsIndex = niuCardsIndex + 1;
		else 
			noniuCards[noniuCardsIndex] = cards[i];
			noniuCardsIndex = noniuCardsIndex + 1;
		end
		lastId = cardId;
	end

	--ngx.say("---------------分割线----------------");
		-- 将特殊的情况先判断和排除 
    table.sort(cardsNumb,niuniu_comp); 
    -- 判断10小
    if table.getn(noniuCards) == 5 then
    	local sumRes = 0;
    	for i=1,5,1 do
    		sumRes = sumRes + cards[i].cardId;
    	end
    	if sumRes < 10 then
    		return  NNCardType.LessTen ,cards
    	end 
    end

    --[[]]
    -- 判断炸弹
    if cardsNumb[1].cardCounts == 4 then
    	-- 当前是炸弹 
    	newCards = cardsNumb[1].cards;
    	table.arrayMerge(newCards,cardsNumb[2]);
    	return NNCardType.Bomb ,newCards
    end

    -- 判断金花
    if table.getn(huaCards) == 5 then  
    	return NNCardType.FiveJinhua ,cards
    end
    -- 判断银花
    if table.getn(huaCards) == 4  and table.getn(niuCards) == 5 then  
    	return NNCardType.FourJinhua, cards
    end

    -- 判断5张10点 牛牛 
    if table.getn(niuCards) == 5 then  
    	return NNCardType.Ten_Niu, cards
    end
    -- 判断 4个点数为10 返回对应的几牛  
    if table.getn(niuCards) == 4 then  
    	local yushu = noniuCards[1].cardValue;
    	return NNCardType[NNCardTypeMap[yushu]], cards
    end

    -- 如果是3个10点牌则进行直接牛牛判断 -- 存在牛牛的牌形
 	if table.getn(niuCards) == 3 then
 		local niushu = noniuCards[1].cardValue + noniuCards[2].cardValue;
 		local yushu = niushu %10;
 		if yushu == 0 then
 			return NNCardType.Ten_Niu, cards
 		end 
    	return NNCardType[NNCardTypeMap[yushu]], cards
    end

   
    -- 其余的组合情况通过系统穷举法,取出三张和剩下2张的组合配置
    -- 首先记录下三张为10的情况,如果三张为牛,则将该牌记录下来,计算后面的两张牌的组合数值 
    local t3Cards ,t2Cards = _NNPoker.C_M_3(cards);
    local t3Index = 1;
    local cardsType = {};
    --ngx.say(table.getn(t3Cards)," ",table.getn(t2Cards))

    for i = 1,table.getn(t3Cards),1 do
    	local cards3Tem = t3Cards[i];
		local cards2Tem = t2Cards[i];
        local card31 =   cards3Tem[1].cardId > 10 and 10 or cards3Tem[1].cardId;
        local card32 =   cards3Tem[2].cardId > 10 and 10 or cards3Tem[2].cardId;
        local card33 =   cards3Tem[3].cardId > 10 and 10 or cards3Tem[3].cardId;
        local card21 =   cards2Tem[1].cardId > 10 and 10 or cards2Tem[1].cardId;
        local card22 =   cards2Tem[2].cardId > 10 and 10 or cards2Tem[2].cardId;

    	local t3Sum = card31 + card32  + card33; 
    	-- 如果三张牌不是10的倍数 则返回说明该牌不是 牛牌
    	local yushu3 = t3Sum % 10; 
    	if yushu3 ~= 0 then 
    		cardsType[t3Index] = NNCardType.NoNiu;  
    	else
    		--[[ ]]
    		-- 等于0 说明有牛 ,判断后两位是否为10的倍数
    		--local card21 =   t2Cards[1].cardId > 10 and 10 or t2Cards[1].cardId;
            --local card22 =   t2Cards[2].cardId > 10 and 10 or t2Cards[2].cardId;

    		local t2Sum = card21 +  card22;
    		local yushu2 = t2Sum % 10;
    		if yushu2 ~= 0 then
    			cardsType[t3Index] = NNCardType[ NNCardTypeMap[yushu2] ]
    		else
    			-- 如果前后都为牛,则 本牌为牛牛
    			cardsType[t3Index] =  NNCardType.Ten_Niu;
    			-- 牛牛的话 直接返回
    			return NNCardType.Ten_Niu, {t3Cards[i][1],t3Cards[i][2],t3Cards[i][3] ,t2Cards[i][1],t2Cards[i][2]};
    		end 
    	end 
    	t3Index = t3Index + 1;
    end 
     
 	local maxType = nil;
    local maxIndex = 1;
    for i = 1,table.getn(cardsType),1 do
    	if not maxType  then 
    		maxType = cardsType[i];
    	else
    		local bRes = maxType > cardsType[i];
    		if not bRes then 
    			maxType = cardsType[i];
    			maxIndex = i;
    		end  
    	end 
    end
    if maxType == _NNPoker.NNCardType.NoNiu then return maxType,cards end;
    
    return maxType,{t3Cards[maxIndex][1],t3Cards[maxIndex][2],t3Cards[maxIndex][3] ,t2Cards[maxIndex][1],t2Cards[maxIndex][2]}; 
 --[[]]
end

--[[
	玩家两组牌 返回当前玩家最大的组合卡牌
	牌为5张
 
-- @param cards 用户5张卡牌的数组 扑克牌必须排序
-- @return 返回当前卡牌的组合的最大类型
]]
function _NNPoker.jugeCards(cards1,cards2)
	local cards1Type ,resCards1= _NNPoker.getCardsMaxType(cards1)
	local cards2Type ,resCards2= _NNPoker.getCardsMaxType(cards2)
	if cards1Type ~= cards2Type then
		return cards1Type > cards2Type and true or false  ,cards1Type, cards2Type ,resCards1,resCards2 ;
	else
		if cards1[1].cardId ~= cards2[2].cardId then
			return cards1[1].cardId > cards2[2].cardId  and true or false   ,cards1Type, cards2Type ,resCards1,resCards2 ;
		else
			return cards1[1].cardSuit > cards2[2].cardSuit  and true or false,cards1Type, cards2Type ,resCards1,resCards2 ;
		end
	end
end

local testCards = { 
	 {cardId = Poker.CardIDType.Ace,    cardValue = Poker.CardValues.Ace,      cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
     {cardId = Poker.CardIDType.Nine,   cardValue = Poker.CardValues.Nine,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Two,    cardValue = Poker.CardValues.Two,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Jack,  cardValue = Poker.CardValues.Jack,      cardSuit = Poker.SuitType.Diamons , IsUsed = 0},
     {cardId = Poker.CardIDType.Jack,   cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
}

local testCards10x = { 
	 {cardId = Poker.CardIDType.Ace,    cardValue = Poker.CardValues.Ace,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Ace,    cardValue = Poker.CardValues.Ace,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Two,    cardValue = Poker.CardValues.Two,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Three,    cardValue = Poker.CardValues.Three,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Three,   cardValue = Poker.CardValues.Three,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
}
local testCardsBo = { 
	 
     {cardId = Poker.CardIDType.Three,    cardValue = Poker.CardValues.Three,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Three,    cardValue = Poker.CardValues.Three,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Three,    cardValue = Poker.CardValues.Three,  cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Three,   cardValue = Poker.CardValues.Three,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Ace,    cardValue = Poker.CardValues.Ace,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
} 
local testCardsJinhua = { 
	 
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Queen,    cardValue = Poker.CardValues.Queen,  cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Queen,   cardValue = Poker.CardValues.Queen,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
} 

local testCardsyinhua = { 
	 
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Queen,    cardValue = Poker.CardValues.Queen,  cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Queen,   cardValue = Poker.CardValues.Queen,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Ten,    cardValue = Poker.CardValues.Ten,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
} 

local testCards10niu = { 
	 
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Queen,    cardValue = Poker.CardValues.Queen,  cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Ten,   cardValue = Poker.CardValues.Ten,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Ten,    cardValue = Poker.CardValues.Ten,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
} 

local testCards410niu = { 
	 
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Queen,    cardValue = Poker.CardValues.Queen,  cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Ten,   cardValue = Poker.CardValues.Ten,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Nine,    cardValue = Poker.CardValues.Nine,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
} 
local testCards3101niu = { 
	 
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Queen,    cardValue = Poker.CardValues.Queen,  cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Five,   cardValue = Poker.CardValues.Five,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Five,    cardValue = Poker.CardValues.Five,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
} 
local testCards3102niu = { 
	 
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Queen,    cardValue = Poker.CardValues.Queen,  cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Five,   cardValue = Poker.CardValues.Five,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Four,    cardValue = Poker.CardValues.Four,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
} 

local testCards2xx1niu = { 
	 
     {cardId = Poker.CardIDType.Jack,    cardValue = Poker.CardValues.Jack,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Seven,    cardValue = Poker.CardValues.Seven,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Three,    cardValue = Poker.CardValues.Three,  cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Eight,   cardValue = Poker.CardValues.Eight,     cardSuit = Poker.SuitType.Spades , IsUsed = 0},
     {cardId = Poker.CardIDType.Five,    cardValue = Poker.CardValues.Five,      cardSuit = Poker.SuitType.Spades , IsUsed = 0},
} 

--[[

table.sort(testCardsJinhua,Poker.card_comp)  
table.sort(testCards3101niu,Poker.card_comp)  

local res ,carts1T,carts2T,resCards1,resCards2 = _NNPoker.jugeCards(testCardsJinhua,testCards3101niu)
 
local bigT = res and carts1T or carts2T;
local bigCards = res and resCards1 or resCards2

-- local cardType, newcards  = _NNPoker.getCardsMaxType(testCards2xx1niu)
-- ngx.say(res,_NNPoker.CardTypeDescription[bigT+1],cjson.encode(bigCards))
]]


return _NNPoker