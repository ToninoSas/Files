-- Carmen, la guerriera S.A.F.
local s, id = GetID()

function s.initial_effect(c)
    -- Pendulum Attribute
    -- Pendulum.AddProcedure(c) EDOPRO
    aux.EnablePendulumAttribute(c)
    -- Pendulum Effect 1: Add "Tonino, il guerriero S.A.F." from Deck to hand
    local e1 = Effect.CreateEffect(c)
    -- e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.pendulumCondition)
    e1:SetTarget(s.pendulumTarget)
    e1:SetOperation(s.pendulumOperation)
    c:RegisterEffect(e1)
    
    -- Pendulum Effect 2: Negate Spell/Trap effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.negateCondition)
    e2:SetCost(s.negateCost)
    e2:SetTarget(s.negateTarget)
    e2:SetOperation(s.negateOperation)
    c:RegisterEffect(e2)
    
    -- Monster Effect: Move to Pendulum Zone
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1, id + 2)
    e3:SetTarget(s.pendulumMoveTarget)
    e3:SetOperation(s.pendulumMoveOperation)
    c:RegisterEffect(e3)
end

function s.myfilter(c)
    return c:IsType(TYPE_PENDULUM)
end
-- Pendulum Effect 1: Condition
function s.pendulumCondition(e, tp, eg, ep, ev, re, r, rp)
    return not Duel.IsExistingMatchingCard(s.myfilter, tp, LOCATION_PZONE, 0, 1, e:GetHandler())
end


-- Pendulum Effect 1: Target
function s.pendulumTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

-- Pendulum Effect 1: Operation
function s.pendulumOperation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end

function s.thfilter(c)
    return c:IsCode(21000001) and c:IsAbleToHand()
end

-- Pendulum Effect 2: Condition
function s.negateCondition(e, tp, eg, ep, ev, re, r, rp)
    return re:IsActiveType(TYPE_SPELL + TYPE_TRAP) and Duel.IsChainNegatable(ev) and rp == 1 - tp
end

-- Pendulum Effect 2: Cost
function s.negateCost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, s.cfilter, 1, 1, REASON_COST + REASON_DISCARD, nil)
end

function s.cfilter(c)
    return c:IsSetCard(0x81c) and c:IsDiscardable()
end

-- Pendulum Effect 2: Target
function s.negateTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsChainNegatable(ev) end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
end

-- Pendulum Effect 2: Operation
function s.negateOperation(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
end

-- Monster Effect: Move to Pendulum Zone
function s.pendulumMoveTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1) end
end

function s.pendulumMoveOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true) then
        Duel.RaiseEvent(c, EVENT_CUSTOM + id, e, 0, tp, 0, 0)
    end
end
