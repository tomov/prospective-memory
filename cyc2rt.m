function RTs = cyc2rt( cycles, intercept )
    if intercept
        RTs = cycles * 10 + 356;
    else
        RTs = cycles * 10;
    end
end

