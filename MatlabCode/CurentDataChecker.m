for i = 1:2602
    for j = 1:902
        for k = 1:24
            if currentNorth(i,j,1,k) ~= 0
                disp([num2str(i),num2str(j),num2str(k)])
            end
            if currentEast(i,j,1,k) ~= 0
                disp([num2str(i),num2str(j),num2str(k)])
            end
        end
    end
end