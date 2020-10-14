for i = 1:2602
    for j = 1:902
        for k = 1:48
            if windEast(i,j,k) ~= 0
                disp([num2str(i),num2str(j),num2str(k)])
            end
            if windNorth(i,j,k) ~= 0
                disp([num2str(i),num2str(j),num2str(k)])
            end
        end
    end
end