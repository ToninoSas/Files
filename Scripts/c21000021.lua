--Lorenzo, il guerriero S.A.F.
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    aux.AddLinkProcedure(c,s.matfilter,2,99, s.lcheck)
    
    -- Link.AddProcedure(c,s.matfilter, 2,99, s.lcheck) EDO PRO
    c:EnableReviveLimit()


    -- Cannot be used as Link Material this turn
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCondition(s.linkcon)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)

    --ATK boost and DEF to 0
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.atktg)
    e2:SetValue(400)
    c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e3:SetValue(0)
    c:RegisterEffect(e3)

    -- Double ATK and destroy
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.dblatktg)
    -- e4:SetCost(s.discost)
    -- e4:SetTarget(s.distg)

    e4:SetOperation(s.dblatkop)
    c:RegisterEffect(e4)
end

function s.linkcon(e)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- Link Material check
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(s.mfilter,1,nil)
end

-- Auxiliary function to check for Level/Rank/Link 6
function s.mfilter(c)
    return c:IsLevelAbove(6) or c:IsRankAbove(6) or c:IsLinkAbove(6)
end

-- Material filter
function s.matfilter(c)
    return c:IsSetCard(0x81c)
end


function s.atktg(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end

-- Double ATK target
function s.dblatktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) and s.atktg(e,chkc) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():GetLinkedGroup():IsExists(Card.IsFaceup, 1, nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=e:GetHandler():GetLinkedGroup():FilterSelect(tp,Card.IsFaceup,1,1,nil)
    Duel.SetTargetCard(g)
end

-- Double ATK operation
function s.dblatkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(tc:GetAttack()*2)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        -- Destroy at End Phase
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE+PHASE_END)
        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetCountLimit(1)
        e2:SetLabelObject(tc)
        e2:SetCondition(s.descon)
        e2:SetOperation(s.desop)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
    end
end

-- Destroy condition
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    return tc and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE)
end

-- Destroy operation
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end