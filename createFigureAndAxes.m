    function [hFig, hAxes] = createFigureAndAxes()

        % Close figure opened by last run
        figTag = 'CVST_VideoOnAxis_9804532';
        close(findobj('tag',figTag));

        % Create new figure
        hFig = figure('numbertitle', 'off', ...
               'name', 'Demostración del algoritmo', ...
               'menubar','none', ...
               'toolbar','none', ...
               'resize', 'on', ...
               'tag',figTag, ...
               'position',[0 0 2048 1024],...
               'HandleVisibility','callback'); % hide the handle to prevent unintended modifications of our custom UI

        % Create axes and titles
        hAxes.pict1 = createPanelAxisTitle(hFig,[0.18 0.5 0.3 0.4],'Puntos trackeados'); % [X Y W H]
        hAxes.pict2 = createPanelAxisTitle(hFig,[0.54 0.5 0.3 0.4],'BoundingBox de los puntos');
        hAxes.axis1 = createPanelAxisTitle(hFig,[0.025 0.05 0.3 0.4],'Video original');
        hAxes.axis2 = createPanelAxisTitle(hFig,[0.35 0.05 0.3 0.4],'Selección trackeada');
        hAxes.axis3 = createPanelAxisTitle(hFig,[0.675 0.05 0.3 0.4],'Selección estabilizada');
    
    end