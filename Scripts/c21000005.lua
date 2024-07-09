--Hyundai I10, il veicolo S.A.F.
local s,id,o=GetID()

c21000005.counter_assicurazione = 0x1000

function c21000005.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1, id)
    e1:SetDescription(aux.Stringid(id,0))
-- devono esserci gatterman nel deck
    e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- se viene evocato special
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- Place Insurance Counter and reduce ATK
	local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_COUNTER + CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1, id)
    e3:SetCondition(c21000005.ctcon)
    e3:SetTarget(c21000005.cttg)
    e3:SetOperation(c21000005.ctop)
    c:RegisterEffect(e3)
end

-- devono esserci gatterman nel deck
function c21000005.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetMatchingGroup(c21000005.filter,tp,LOCATION_DECK,0,nil):GetCount()>0 
        and not Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_FZONE, 0, 1, nil, TYPE_FIELD)
end

function c21000005.filter(c, tp)
	return c:IsCode(21000006)
end

function c21000005.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c21000005.filter,tp,LOCATION_DECK,0,nil)

	if g:GetCount()>0 then

        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local tc=Duel.SelectMatchingCard(tp,c21000005.filter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
        if tc then
            Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
        end
	end
end

function c21000005.ctcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_BATTLE) and c:GetBattleTarget() ~= nil
end

function c21000005.cttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_COUNTER, nil, 1, 0, 0)
end

function c21000005.ctop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = c:GetBattleTarget()
    if tc and tc:IsRelateToBattle() then
        tc:AddCounter(c21000005.counter_assicurazione, 1) -- Replace 0x1 with the actual counter ID for Insurance Counter
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
