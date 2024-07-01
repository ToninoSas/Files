-- Tonino, il guerriero S.A.F.
local s, id = GetID()

function s.initial_effect(c)
    -- Effetto Pendulum
    -- Pendulum.AddProcedure(c) EDOPRO
    aux.EnablePendulumAttribute(c)
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetCode(EVENT_PHASE + PHASE_STANDBY)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCondition(s.pendulumCondition)
    e1:SetTarget(s.pendulumTarget)
    e1:SetOperation(s.pendulumOperation)
    e1:SetCountLimit(1, id)
    c:RegisterEffect(e1)

    -- Pendulum Effect 2: Move from Pendulum Zone to Monster Zone
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1, id + 1)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    -- Monster Effect: Negate attack and move to Pendulum Zone
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BE_BATTLE_TARGET)
    e3:SetCountLimit(1, id + 2)
    e3:SetCondition(s.atkcon)
    e3:SetTarget(s.atktg)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

-- Effetto Pendulum: Mandare una carta "S.A.F." dal Deck al Cimitero se si controlla "Carmen, la guerriera S.A.F."
function s.pendulumCondition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.isCarmen, tp, LOCATION_PZONE, 0, 1, nil)
end

function s.isCarmen( c )
    return c:IsCode(21000003)
end

function s.pendulumTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsSetCard, tp, LOCATION_DECK, 0, 1, nil, 0x81c) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.pendulumOperation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, Card.IsSetCard, tp, LOCATION_DECK, 0, 1, 1, nil, 0x81c)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end

-- effetto 2, sposto da pendulum a monster
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 end
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.MoveToField(c, tp, tp, LOCATION_MZONE, POS_FACEUP, true) then
        Duel.RaiseSingleEvent(c, EVENT_CUSTOM + id, e, 0, tp, 0, 0)
    end
end

-- effetto 3, se viene attaccato, annullo l'attacco e lo mando nella zona pendulum
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.GetAttacker() and Duel.GetAttackTarget() == c
end

function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        return Duel.CheckPendulumZones(tp) 
    end
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.NegateAttack() and c:IsRelateToBattle() and Duel.CheckPendulumZones(tp) then
        Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end
end

-- Function to check if Pendulum Zones are available
function Duel.CheckPendulumZones(tp)
    return Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)
end