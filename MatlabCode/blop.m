for i = 1:2602
    for j = 1:902
        for k = 1:48
            if currentEast(i,j,k) ~= 0
                disp([num2str(i),num2str(j),num2str(k)])
            end
            if currentNorth(i,j,k) ~= 0
                disp([num2str(i),num2str(j),num2str(k)])
            end
        end
    end
end