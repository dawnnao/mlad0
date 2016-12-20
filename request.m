function go = request(head, tail, savePath, fileName, preset)
% not using!

if ~exist('preset', 'var'), preset = []; end

if strcmp(preset, 'y')  || strcmp(preset, 'yes')
    go = 'y';
    fprintf('\n%s\n\n\n', tail)
elseif strcmp(preset, 'n')  || strcmp(preset, 'no')
    go = 'n';
    fprintf('\nSaving results...\nLocation: %s\n', savePath)
    if exist([savePath '/' fileName], 'file')
        delete([savePath '/' fileName]);
    end
    save([savePath '/' fileName], '-v7.3')
    fprintf('\nFinish! Check data status in sensor.status .\n')
    return
else
    fprintf('\n%s\n', head)
    rightInput = 0;
    while rightInput == 0
        prompt = 'y(yes)/n(no): ';
        go = input(prompt,'s');
        if strcmp(go,'y') || strcmp(go,'yes')
            rightInput = 1;
            fprintf('\n%s\n\n\n', tail)
        elseif strcmp(go,'n') || strcmp(go,'no')
            rightInput = 1;
            fprintf('\nSaving results...\nLocation: %s\n', savePath)
            if exist([savePath '/' fileName], 'file')
                delete([savePath '/' fileName]);
            end
            save([savePath '/' fileName])
            fprintf('\nFinish! Check data status in sensor.status .\n')
            return
        else
            fprintf('Invalid input! Please re-input.\n')
        end
    end
end
pause(2)

end