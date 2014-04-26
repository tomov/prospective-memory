function RTs = cyc2rt( cycles, intercept )
    if intercept
        RTs = cycles * 12 + 150;
    else
        RTs = cycles * 12;
    end
end

