-- Gianluca, il guerriero S.A.F.
local s, id = GetID()

function s.initial_effect(c)
    -- Once per turn, pay 500 LP, draw 1 card; if it's a monster, add it to your hand, if it's a Spell/Trap, send it to the GY
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.drcost)
    e1:SetTarget(s.drtg)
    e1:SetOperation(s.drop)
    c:RegisterEffect(e1)
end

function s.drcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 500) end
    Duel.PayLPCost(tp, 500)
end

function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.drop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetDecktopGroup(tp, 1):GetFirst()
    if not tc then return end
    Duel.Draw(tp, 1, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
    if tc:IsType(TYPE_MONSTER) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
    else
        Duel.SendtoGrave(tc, REASON_EFFECT)
    end
    Duel.ShuffleHand(tp)
end
