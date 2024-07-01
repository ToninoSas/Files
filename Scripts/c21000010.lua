--Andrea, il guerriero S.A.F.
--Andrea, il guerriero S.A.F.
local s,id=GetID()
function c21000010.initial_effect(c)
	--Halve the ATK of 1 face-up monster on the field
	local e1=Effect.CreateEffect(c)
	-- e1:SetDescription(aux.Stringid(c21000010,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1, 21000010)
	e1:SetTarget(c21000010.atktg)
	e1:SetOperation(c21000010.atkop)
	c:RegisterEffect(e1)

	-- se viene evocato special
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- Effect 3: Special Summon from GY when a "S.A.F." monster is destroyed
    local e3 = Effect.CreateEffect(c)
    -- e3:SetDescription(aux.Stringid(21000010, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(c21000010.spcon)
    e3:SetTarget(c21000010.sptg)
    e3:SetOperation(c21000010.spop)
    e3:SetCountLimit(1, 21000010)
    c:RegisterEffect(e3)
end

function c21000010.atktgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function c21000010.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.atktgfilter(chkc) end
	if chk == 0 then return Duel.IsExistingTarget(s.atktgfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
	local g = Duel.SelectTarget(tp, s.atktgfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_ATKCHANGE, g, 1, 0, 0)
end

function c21000010.atkop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk = tc:GetAttack()
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk / 2))
		e1:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

function c21000010.spfilter(c, tp)
	-- eccetto andrea
    return not c:IsCode(21000010) and 
	c:IsControler(tp) and c:IsReason(REASON_BATTLE + REASON_EFFECT) and c:IsSetCard(0x81c) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end

function c21000010.spcon(e, tp, eg, ep, ev, re, r, rp)
	-- eccetto andrea
    return eg:IsExists(c21000010.spfilter, 1, nil, tp) and not eg:IsContains(e:GetHandler())
end

function c21000010.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function c21000010.spop(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsRelateToEffect(e) then
        Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
    end
end
