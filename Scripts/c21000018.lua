-- Francesco, il chitarrista S.A.F.
local s, id = GetID()
function s.initial_effect(c)
    -- XYZ Summon
    -- Xyz.AddProcedure(c, aux.FilterBoolFunction(Card.IsSetCard, 0x81c), 6, 2) EDO PRO

    aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard, 0x81c),6,2)

    c:EnableReviveLimit()
    
    -- Inflict damage on XYZ Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.damcon)
    e1:SetTarget(s.damtg)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)
    
    -- Shuffle banished cards and draw
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.tdcost)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(1500)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 1500)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    Duel.Damage(p, 1500, REASON_EFFECT)
end

function s.tdcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_REMOVED, LOCATION_REMOVED, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 5, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_REMOVED, 0, 1, nil) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
        local g = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_REMOVED, 0, 1, 5, nil)
        if #g > 0 then
            Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
            Duel.Draw(tp, 1, REASON_EFFECT)
        end
    end
end
