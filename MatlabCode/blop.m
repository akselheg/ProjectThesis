for i = 1:2602
    for j = 1:902
        for k = 1:48
            if currentNorth(i,j,k) ~= 0
                disp([i,j,k])
            end
        end
    end
end