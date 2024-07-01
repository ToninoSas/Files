-- Dove la Montagna Incontra il Mare
local s, id = GetID()

function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.con)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsPlayerCanDraw(tp, 3)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsPlayerCanDraw(tp, 3)
    end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 3)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)

    local c = e:GetHandler()
    local g = Duel.GetDecktopGroup(tp, 3)
    if g:GetCount() == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local sg = g:Select(tp, 1, 1, nil)
    Duel.ConfirmCards(1-tp, sg)
    Duel.ConfirmCards(tp, sg)

    Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)
    Duel.SendtoHand(sg, nil, REASON_EFFECT)

end

