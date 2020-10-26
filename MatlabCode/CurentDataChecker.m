flag = false;
for i = 1:2602
    for j = 1:902
        for k = 1:24
            if currentNorth(i,j,k) ~= 0
                flag = true;
            end
            if currentEast(i,j,k) ~= 0
            end
        end
    end
end