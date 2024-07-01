-- Gatterman
local s,id,o=GetID()
function c21000006.initial_effect(c)

    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Increase ATK of "S.A.F." monsters by 200 for each "S.A.F." monster you control
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(c21000006.atktg)
    e1:SetValue(c21000006.atkval)
    c:RegisterEffect(e1)

    -- Add "S.A.F." monster to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(c21000006.thcon)
    e2:SetCost(c21000006.thcost)
    e2:SetTarget(c21000006.thtg)
    e2:SetOperation(c21000006.thop)
    c:RegisterEffect(e2)

    -- -- Activate from hand
    -- local e3 = Effect.CreateEffect(c)
    -- e3:SetType(EFFECT_TYPE_ACTIVATE)
    -- e3:SetCode(EVENT_FREE_CHAIN)
    -- e3:SetRange(LOCATION_HAND)
    -- e3:SetCondition(s.actcon)
    -- e3:SetOperation(s.actop)
    -- c:RegisterEffect(e3)
end

function c21000006.atktg(e, c)
    return c:IsSetCard(0x81c) -- Replace 0xXXX with the actual "S.A.F." archetype code
end

function c21000006.onfield_filter(c)
    return c:IsFaceup() and c:IsSetCard(0x81c) -- Replace 0xXXX with the actual "S.A.F." archetype code
end

function c21000006.atkval(e, c)
    return Duel.GetMatchingGroupCount(c21000006.onfield_filter, c:GetControler(), LOCATION_MZONE, 0, nil) * 200
end

function c21000006.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(c21000006.onfield_filter,tp,LOCATION_MZONE,0,1,nil)
end

function c21000006.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end

function c21000006.thfilter(c)
    return c:IsSetCard(0x81c) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end

function c21000006.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c21000006.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function c21000006.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c21000006.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Activate condition: no Field Spell is active
-- function s.actcon(e, tp, eg, ep, ev, re, r, rp)
--     return not Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_FZONE, 0, 1, nil, TYPE_FIELD)
-- end

-- -- Activate operation: move the card to the field zone
-- function s.actop(e, tp, eg, ep, ev, re, r, rp)
--     local c = e:GetHandler()
--     Duel.MoveToField(c, tp, tp, LOCATION_FZONE, POS_FACEUP, true)
-- end