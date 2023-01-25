classdef main < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        LeftPanel          matlab.ui.container.Panel
        Label_26           matlab.ui.control.Label
        Label_25           matlab.ui.control.Label
        Label_24           matlab.ui.control.Label
        Label_23           matlab.ui.control.Label
        Label_22           matlab.ui.control.Label
        Label_21           matlab.ui.control.Label
        Label_20           matlab.ui.control.Label
        Label_17           matlab.ui.control.Label
        startButton        matlab.ui.control.StateButton
        Label_10           matlab.ui.control.Label
        Label_9            matlab.ui.control.Label
        Label_8            matlab.ui.control.Label
        costFighter        matlab.ui.control.NumericEditField
        Label_7            matlab.ui.control.Label
        c_3Label           matlab.ui.control.Label
        c_1Label           matlab.ui.control.Label
        costFire           matlab.ui.control.NumericEditField
        Label_5            matlab.ui.control.Label
        t_1Label           matlab.ui.control.Label
        timeBegin          matlab.ui.control.NumericEditField
        Label_4            matlab.ui.control.Label
        betaLabel          matlab.ui.control.Label
        speedFire          matlab.ui.control.NumericEditField
        Label_3            matlab.ui.control.Label
        c_2Label           matlab.ui.control.Label
        costTime           matlab.ui.control.NumericEditField
        Label_6            matlab.ui.control.Label
        lambdaLabel        matlab.ui.control.Label
        speedFighter       matlab.ui.control.NumericEditField
        Label_2            matlab.ui.control.Label
        xLabel             matlab.ui.control.Label
        fighter            matlab.ui.control.Spinner
        Label              matlab.ui.control.Label
        RightPanel         matlab.ui.container.Panel
        Label_31           matlab.ui.control.Label
        Label_30           matlab.ui.control.Label
        ForestLabel        matlab.ui.control.Label
        Label_28           matlab.ui.control.Label
        Label_27           matlab.ui.control.Label
        outputCostForest   matlab.ui.control.Label
        outputCostFighter  matlab.ui.control.Label
        outputCostTotal    matlab.ui.control.Label
        outputArea         matlab.ui.control.Label
        outputTime         matlab.ui.control.Label
        Label_15           matlab.ui.control.Label
        Label_14           matlab.ui.control.Label
        Label_13           matlab.ui.control.Label
        Label_12           matlab.ui.control.Label
        Label_11           matlab.ui.control.Label
        AxesForest         matlab.ui.control.UIAxes
        AxesBurned         matlab.ui.control.UIAxes
        AxesTotalCost      matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: startButton
        function startButtonValueChanged(app, event)
            % read input values
            value = app.startButton.Value;
            X = app.fighter.Value;
            lambda = app.speedFighter.Value;
            beta = app.speedFire.Value;
            t_1 = app.timeBegin.Value;

            cla(app.AxesBurned);
            cla(app.AxesTotalCost);
            cla(app.AxesForest);

            if lambda * X < beta 
                fig = app.UIFigure;
                message = {'灭火速度小于火势蔓延速度,无法灭火!', ...
                    '请增加消防员数量/增大消防员灭火速度/减小火势蔓延速度'};
                uialert(fig,message,'参数错误');
                pause;
            
            else
                c_1 = app.costFire.Value;
                c_2 = app.costTime.Value;
                c_3 = app.costFighter.Value;
    
                % calculate burned area until t_1
                func_1 = @(t) beta * t;
                B = integral(func_1,0,t_1);
    
                app.outputArea.Text = num2str(B,'%.2f') + "亩";
    
                % calculate t_2, time required to put out fire 
                % func_2, the area after t_1
                func_2 = @(t) integral(@(t)(beta - lambda * X) * t,t_1,t) + B;
                options = optimoptions('fsolve', 'TolFun', 1e-6, 'TolX', 1e-6);
                % use fsolve to find solution, begin with t_1
                t_2=fsolve(func_2,t_1,options);
    
                app.outputTime.Text = num2str(t_2,'%.2f') + "小时";
                
                % calculate cost
                cost_1 = c_1 * B;
                cost_2 = X * ((t_2 - t_1)* c_2 + c_3);
                costTotal = cost_1 + cost_2;
    
                app.outputCostForest.Text = num2str(cost_1,'%.2f') + "元";
                app.outputCostFighter.Text = num2str(cost_2,'%.2f') + "元";
                app.outputCostTotal.Text = num2str(costTotal,'%.2f') + "元";
    
                %% plot axes
                cla(app.AxesBurned);
                cla(app.AxesTotalCost);
                cla(app.AxesForest);
                
                axis(app.AxesBurned,[0,t_2+0.5,0,B*1.2]);
                axis(app.AxesTotalCost,[0,t_2+0.5,0,costTotal*1.2]);
    
                % axesForest
                len = sqrt(B);
                len = round(len/2);
                lenLong = round(len * 2.5);
                axis(app.AxesForest,[-lenLong,lenLong,-lenLong,lenLong]);
                x = [];
                y = [];

                mapSize = 0.010;
                mapGrow = 150;
                mapPosition = 0.12;
                barGrow = mapGrow/5;
                
                %% before t_1
                app.ForestLabel.Text = "火势扩大中";
                app.ForestLabel.FontColor = '#DE0000';
%                     map = [59 46 126
%                         25 226 187
%                         223 223 55
%                         239 88 17
%                         125 6 4];
                colormap(app.AxesForest,'turbo');

                clear X_1 Yburned_1;
                count = 0;
                for i = 0:0.02:t_1
                    count = count + 1;
                    j = round(i * 50) + 1;

                    X_1(count) = count * 0.02;
                    Yburned_1(count) = integral(@(t) beta * t,0,i);
                    Ycost_1(count) = c_1 * Yburned_1(count);
                    
                    plot(app.AxesBurned,X_1,Yburned_1,'Color','#4D4D4D','LineWidth',2);
                    area(app.AxesBurned,X_1,Yburned_1,'FaceColor','#3399FF');
                    hold(app.AxesBurned,"on");
    
                    plot(app.AxesTotalCost,X_1,Ycost_1,'Color','#4D4D4D','LineWidth',2);
                    area(app.AxesTotalCost,X_1,Ycost_1,'FaceColor','#EDB120');
                    hold(app.AxesTotalCost,"on");
                   
                    % plot the heatmap of fire
                    x = cat(1,x,j*mapSize*len*randn(mapGrow*j,1) + j*mapPosition*(randn()));
                    y = cat(1,y,j*mapSize*len*randn(mapGrow*j,1) + j*mapPosition*(randn()));
                    h = histogram2(app.AxesForest,x,y,'DisplayStyle','tile','ShowEmptyBins','on', ...
                        'facecolor','flat', ...
                        'XBinLimits',[-lenLong lenLong],'YBinLimits',[-lenLong lenLong],'NumBins',2*lenLong); 

                    axMax = round(barGrow*sqrt(j));
                    clim(app.AxesForest,[0 axMax])
                    colorbar(app.AxesForest,'Ticks',[0,axMax*0.4,axMax*0.6,axMax*0.9],...
                        'TickLabels',{'未着火','微弱','中等','严重'});
                                 
                    pause(1/10);
                end
                
                %% after t_1
                app.ForestLabel.Text = "火势减小中";
                app.ForestLabel.FontColor = '#0CF422';

                clear X_2 Yburned_2;
                count_2 = 0;
                % num of fire deleted in one for loop
                num = round(length(x)/((t_2-t_1)/0.02));
                for i = t_1:0.02:t_2
                    count_2 = count_2 + 1;
                    X_2(count_2) = count_2 * 0.02 + t_1;
                    Yburned_2(count_2) = integral(@(t)(beta - lambda * X) * t,t_1,i) + B;
                    Ycost_2(count_2) = cost_1 + X * ((i-t_1)*c_2 + c_3);
                    
                    plot(app.AxesBurned,X_2,Yburned_2,'Color','#4D4D4D','LineWidth',2);
                    area(app.AxesBurned,X_2,Yburned_2,'FaceColor','#3399FF');
                    hold(app.AxesBurned,"on");
    
                    plot(app.AxesTotalCost,X_2,Ycost_2,'Color','#4D4D4D','LineWidth',2);
                    area(app.AxesTotalCost,X_2,Ycost_2,'FaceColor','#EDB120');
                    hold(app.AxesTotalCost,"on");

                    x = x(1:length(x)-num);
                    y = y(1:length(y)-num);
                    h = histogram2(app.AxesForest,x,y,'DisplayStyle','tile','ShowEmptyBins','on', ...
                        'facecolor','flat', ...
                        'XBinLimits',[-lenLong lenLong],'YBinLimits',[-lenLong lenLong],'NumBins',2*lenLong);   

                    j = j - j/((t_2-t_1)/0.02)*0.15;
                    axMax = round(barGrow*sqrt(j));
                    clim(app.AxesForest,[0 axMax])
                    colorbar(app.AxesForest,'Ticks',[0,axMax*0.4,axMax*0.6,axMax*0.9],...
                        'TickLabels',{'未着火','微弱','中等','严重'});
                                                     
                    pause(1/10);
                end
                x = [];
                y = [];
                h = histogram2(app.AxesForest,x,y,'DisplayStyle','tile','ShowEmptyBins','on', ...
                        'facecolor','flat', ...
                        'XBinLimits',[-lenLong lenLong],'YBinLimits',[-lenLong lenLong],'NumBins',2*lenLong);
                hold(app.AxesBurned,"on");
                hold(app.AxesTotalCost,"on");
                hold(app.AxesForest,"on");
                app.ForestLabel.Text = "火势已扑灭";
                app.ForestLabel.FontColor = '#FFCF05';

                fig = app.UIFigure;
                message = {'仿真结束!', ...
                    '点击开始仿真可以进行下一次仿真'};
                uialert(fig,message,'成功','Icon','success');
            end


            
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {720, 720};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {421, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1280 720];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {421, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.BorderType = 'none';
            app.LeftPanel.BackgroundColor = [0.1804 0.1804 0.1804];
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create Label
            app.Label = uilabel(app.LeftPanel);
            app.Label.HorizontalAlignment = 'right';
            app.Label.FontName = 'Microsoft YaHei UI';
            app.Label.FontSize = 18;
            app.Label.FontColor = [0.9412 0.9412 0.9412];
            app.Label.Position = [79 517 131 23];
            app.Label.Text = '派出消防员数量';

            % Create fighter
            app.fighter = uispinner(app.LeftPanel);
            app.fighter.Limits = [1 Inf];
            app.fighter.RoundFractionalValues = 'on';
            app.fighter.ValueDisplayFormat = '%.0f';
            app.fighter.FontName = 'Microsoft YaHei UI';
            app.fighter.FontSize = 16;
            app.fighter.Position = [260 517 63 22];
            app.fighter.Value = 15;

            % Create xLabel
            app.xLabel = uilabel(app.LeftPanel);
            app.xLabel.Interpreter = 'latex';
            app.xLabel.HorizontalAlignment = 'center';
            app.xLabel.FontSize = 18;
            app.xLabel.FontColor = [0.9412 0.9412 0.9412];
            app.xLabel.Position = [208 516 25 24];
            app.xLabel.Text = '$x$';

            % Create Label_2
            app.Label_2 = uilabel(app.LeftPanel);
            app.Label_2.HorizontalAlignment = 'right';
            app.Label_2.FontName = 'Microsoft YaHei UI';
            app.Label_2.FontSize = 18;
            app.Label_2.FontColor = [0.9412 0.9412 0.9412];
            app.Label_2.Position = [79 478 149 23];
            app.Label_2.Text = '每人平均灭火速度';

            % Create speedFighter
            app.speedFighter = uieditfield(app.LeftPanel, 'numeric');
            app.speedFighter.Limits = [0 Inf];
            app.speedFighter.ValueDisplayFormat = '%.2f';
            app.speedFighter.Position = [260 478 60 22];
            app.speedFighter.Value = 8;

            % Create lambdaLabel
            app.lambdaLabel = uilabel(app.LeftPanel);
            app.lambdaLabel.Interpreter = 'latex';
            app.lambdaLabel.HorizontalAlignment = 'center';
            app.lambdaLabel.FontSize = 18;
            app.lambdaLabel.FontColor = [0.9412 0.9412 0.9412];
            app.lambdaLabel.Position = [227 477 25 24];
            app.lambdaLabel.Text = '$\lambda$';

            % Create Label_6
            app.Label_6 = uilabel(app.LeftPanel);
            app.Label_6.HorizontalAlignment = 'right';
            app.Label_6.FontName = 'Microsoft YaHei UI';
            app.Label_6.FontSize = 18;
            app.Label_6.FontColor = [0.9412 0.9412 0.9412];
            app.Label_6.Position = [78 275 149 23];
            app.Label_6.Text = '每人单位时间支出';

            % Create costTime
            app.costTime = uieditfield(app.LeftPanel, 'numeric');
            app.costTime.Limits = [0 Inf];
            app.costTime.ValueDisplayFormat = '%.2f';
            app.costTime.Position = [260 275 60 22];
            app.costTime.Value = 182.5;

            % Create c_2Label
            app.c_2Label = uilabel(app.LeftPanel);
            app.c_2Label.Interpreter = 'latex';
            app.c_2Label.HorizontalAlignment = 'center';
            app.c_2Label.FontSize = 18;
            app.c_2Label.FontColor = [0.9412 0.9412 0.9412];
            app.c_2Label.Position = [229 273 25 26];
            app.c_2Label.Text = '$c_2$';

            % Create Label_3
            app.Label_3 = uilabel(app.LeftPanel);
            app.Label_3.HorizontalAlignment = 'right';
            app.Label_3.FontName = 'Microsoft YaHei UI';
            app.Label_3.FontSize = 18;
            app.Label_3.FontColor = [0.9412 0.9412 0.9412];
            app.Label_3.Position = [79 439 113 23];
            app.Label_3.Text = '火势蔓延速度';

            % Create speedFire
            app.speedFire = uieditfield(app.LeftPanel, 'numeric');
            app.speedFire.Limits = [0 Inf];
            app.speedFire.ValueDisplayFormat = '%.2f';
            app.speedFire.Position = [260 439 60 22];
            app.speedFire.Value = 100;

            % Create betaLabel
            app.betaLabel = uilabel(app.LeftPanel);
            app.betaLabel.Interpreter = 'latex';
            app.betaLabel.HorizontalAlignment = 'center';
            app.betaLabel.FontSize = 18;
            app.betaLabel.FontColor = [0.9412 0.9412 0.9412];
            app.betaLabel.Position = [190 438 25 24];
            app.betaLabel.Text = '$\beta$';

            % Create Label_4
            app.Label_4 = uilabel(app.LeftPanel);
            app.Label_4.HorizontalAlignment = 'right';
            app.Label_4.FontName = 'Microsoft YaHei UI';
            app.Label_4.FontSize = 18;
            app.Label_4.FontColor = [0.9412 0.9412 0.9412];
            app.Label_4.Position = [79 400 113 23];
            app.Label_4.Text = '开始救火时刻';

            % Create timeBegin
            app.timeBegin = uieditfield(app.LeftPanel, 'numeric');
            app.timeBegin.Limits = [0.01 Inf];
            app.timeBegin.ValueDisplayFormat = '%.1f';
            app.timeBegin.Position = [260 400 60 22];
            app.timeBegin.Value = 1.7;

            % Create t_1Label
            app.t_1Label = uilabel(app.LeftPanel);
            app.t_1Label.Interpreter = 'latex';
            app.t_1Label.HorizontalAlignment = 'center';
            app.t_1Label.FontSize = 18;
            app.t_1Label.FontColor = [0.9412 0.9412 0.9412];
            app.t_1Label.Position = [191 398 25 26];
            app.t_1Label.Text = '$t_1$';

            % Create Label_5
            app.Label_5 = uilabel(app.LeftPanel);
            app.Label_5.HorizontalAlignment = 'right';
            app.Label_5.FontName = 'Microsoft YaHei UI';
            app.Label_5.FontSize = 18;
            app.Label_5.FontColor = [0.9412 0.9412 0.9412];
            app.Label_5.Position = [78 312 149 23];
            app.Label_5.Text = '单位烧毁面积损失';

            % Create costFire
            app.costFire = uieditfield(app.LeftPanel, 'numeric');
            app.costFire.Limits = [0 Inf];
            app.costFire.ValueDisplayFormat = '%.2f';
            app.costFire.Position = [260 312 60 22];
            app.costFire.Value = 725.6;

            % Create c_1Label
            app.c_1Label = uilabel(app.LeftPanel);
            app.c_1Label.Interpreter = 'latex';
            app.c_1Label.HorizontalAlignment = 'center';
            app.c_1Label.FontSize = 18;
            app.c_1Label.FontColor = [0.9412 0.9412 0.9412];
            app.c_1Label.Position = [229 310 25 26];
            app.c_1Label.Text = '$c_1$';

            % Create c_3Label
            app.c_3Label = uilabel(app.LeftPanel);
            app.c_3Label.Interpreter = 'latex';
            app.c_3Label.HorizontalAlignment = 'center';
            app.c_3Label.FontSize = 18;
            app.c_3Label.FontColor = [0.9412 0.9412 0.9412];
            app.c_3Label.Position = [212 237 25 26];
            app.c_3Label.Text = '$c_3$';

            % Create Label_7
            app.Label_7 = uilabel(app.LeftPanel);
            app.Label_7.HorizontalAlignment = 'right';
            app.Label_7.FontName = 'Microsoft YaHei UI';
            app.Label_7.FontSize = 18;
            app.Label_7.FontColor = [0.9412 0.9412 0.9412];
            app.Label_7.Position = [78 239 131 23];
            app.Label_7.Text = '每人一次性支出';

            % Create costFighter
            app.costFighter = uieditfield(app.LeftPanel, 'numeric');
            app.costFighter.Limits = [0 Inf];
            app.costFighter.ValueDisplayFormat = '%.2f';
            app.costFighter.Position = [260 239 60 22];
            app.costFighter.Value = 200;

            % Create Label_8
            app.Label_8 = uilabel(app.LeftPanel);
            app.Label_8.HorizontalAlignment = 'center';
            app.Label_8.FontName = 'STSong';
            app.Label_8.FontSize = 40;
            app.Label_8.FontWeight = 'bold';
            app.Label_8.FontColor = [0.9412 0.9412 0.9412];
            app.Label_8.Position = [45 617 330 53];
            app.Label_8.Text = '森林救火仿真系统';

            % Create Label_9
            app.Label_9 = uilabel(app.LeftPanel);
            app.Label_9.HorizontalAlignment = 'center';
            app.Label_9.FontName = 'Segoe UI Emoji';
            app.Label_9.FontSize = 30;
            app.Label_9.Position = [31 312 47 41];
            app.Label_9.Text = '💰';

            % Create Label_10
            app.Label_10 = uilabel(app.LeftPanel);
            app.Label_10.HorizontalAlignment = 'center';
            app.Label_10.FontName = 'Segoe UI Emoji';
            app.Label_10.FontSize = 30;
            app.Label_10.Position = [30 515 47 41];
            app.Label_10.Text = '🚒';

            % Create startButton
            app.startButton = uibutton(app.LeftPanel, 'state');
            app.startButton.ValueChangedFcn = createCallbackFcn(app, @startButtonValueChanged, true);
            app.startButton.Text = '开始仿真';
            app.startButton.BackgroundColor = [1 1 1];
            app.startButton.FontName = 'Microsoft YaHei UI';
            app.startButton.FontSize = 22;
            app.startButton.FontColor = [0.2706 0.2706 0.2706];
            app.startButton.Position = [138 101 133 52];

            % Create Label_17
            app.Label_17 = uilabel(app.LeftPanel);
            app.Label_17.FontName = 'Microsoft YaHei UI';
            app.Label_17.FontSize = 18;
            app.Label_17.FontAngle = 'italic';
            app.Label_17.FontColor = [0.9412 0.9412 0.9412];
            app.Label_17.Position = [327 516 25 23];
            app.Label_17.Text = '人';

            % Create Label_20
            app.Label_20 = uilabel(app.LeftPanel);
            app.Label_20.FontName = 'Microsoft YaHei UI';
            app.Label_20.FontSize = 18;
            app.Label_20.FontColor = [0.9412 0.9412 0.9412];
            app.Label_20.Position = [327 400 59 23];
            app.Label_20.Text = '小时后';

            % Create Label_21
            app.Label_21 = uilabel(app.LeftPanel);
            app.Label_21.FontName = 'Microsoft YaHei UI';
            app.Label_21.FontSize = 18;
            app.Label_21.FontAngle = 'italic';
            app.Label_21.FontColor = [0.9412 0.9412 0.9412];
            app.Label_21.Position = [327 312 49 23];
            app.Label_21.Text = '元/亩';

            % Create Label_22
            app.Label_22 = uilabel(app.LeftPanel);
            app.Label_22.FontName = 'Microsoft YaHei UI';
            app.Label_22.FontSize = 18;
            app.Label_22.FontAngle = 'italic';
            app.Label_22.FontColor = [0.9412 0.9412 0.9412];
            app.Label_22.Position = [327 275 67 23];
            app.Label_22.Text = '元/小时';

            % Create Label_23
            app.Label_23 = uilabel(app.LeftPanel);
            app.Label_23.FontName = 'Microsoft YaHei UI';
            app.Label_23.FontSize = 18;
            app.Label_23.FontAngle = 'italic';
            app.Label_23.FontColor = [0.9412 0.9412 0.9412];
            app.Label_23.Position = [327 239 49 23];
            app.Label_23.Text = '元/人';

            % Create Label_24
            app.Label_24 = uilabel(app.LeftPanel);
            app.Label_24.FontName = 'Microsoft YaHei UI';
            app.Label_24.FontSize = 18;
            app.Label_24.FontAngle = 'italic';
            app.Label_24.FontColor = [0.9412 0.9412 0.9412];
            app.Label_24.Position = [327 478 67 23];
            app.Label_24.Text = '亩/小时';

            % Create Label_25
            app.Label_25 = uilabel(app.LeftPanel);
            app.Label_25.FontName = 'Microsoft YaHei UI';
            app.Label_25.FontSize = 18;
            app.Label_25.FontAngle = 'italic';
            app.Label_25.FontColor = [0.9412 0.9412 0.9412];
            app.Label_25.Position = [327 439 67 23];
            app.Label_25.Text = '亩/小时';

            % Create Label_26
            app.Label_26 = uilabel(app.LeftPanel);
            app.Label_26.Interpreter = 'latex';
            app.Label_26.HorizontalAlignment = 'center';
            app.Label_26.FontSize = 18;
            app.Label_26.FontColor = [0.9412 0.9412 0.9412];
            app.Label_26.Position = [385 437 25 27];
            app.Label_26.Text = '$^2$';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.BorderType = 'none';
            app.RightPanel.BackgroundColor = [0.651 0.651 0.651];
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create AxesTotalCost
            app.AxesTotalCost = uiaxes(app.RightPanel);
            title(app.AxesTotalCost, '经济损失')
            xlabel(app.AxesTotalCost, '时间')
            ylabel(app.AxesTotalCost, '元')
            zlabel(app.AxesTotalCost, 'Z')
            app.AxesTotalCost.LabelFontSizeMultiplier = 1;
            app.AxesTotalCost.FontName = 'Microsoft YaHei UI';
            app.AxesTotalCost.LineWidth = 1;
            app.AxesTotalCost.Color = [0.651 0.651 0.651];
            app.AxesTotalCost.YGrid = 'on';
            app.AxesTotalCost.FontSize = 14;
            app.AxesTotalCost.Position = [529 25 319 251];

            % Create AxesBurned
            app.AxesBurned = uiaxes(app.RightPanel);
            title(app.AxesBurned, '燃烧区域')
            xlabel(app.AxesBurned, '时间')
            ylabel(app.AxesBurned, '亩')
            zlabel(app.AxesBurned, 'Z')
            app.AxesBurned.LabelFontSizeMultiplier = 1;
            app.AxesBurned.FontName = 'Microsoft YaHei UI';
            app.AxesBurned.LineWidth = 1;
            app.AxesBurned.Color = [0.651 0.651 0.651];
            app.AxesBurned.YGrid = 'on';
            app.AxesBurned.FontSize = 14;
            app.AxesBurned.GridColor = [0.149 0.149 0.149];
            app.AxesBurned.GridAlpha = 0.25;
            app.AxesBurned.Position = [529 281 319 243];

            % Create AxesForest
            app.AxesForest = uiaxes(app.RightPanel);
            app.AxesForest.LineWidth = 1;
            app.AxesForest.Color = [0.1882 0.0706 0.2314];
            colormap(app.AxesForest, 'turbo')
            app.AxesForest.Position = [10 25 512 475];

            % Create Label_11
            app.Label_11 = uilabel(app.RightPanel);
            app.Label_11.FontName = 'Microsoft YaHei UI';
            app.Label_11.FontSize = 20;
            app.Label_11.FontWeight = 'bold';
            app.Label_11.FontColor = [0.1882 0.1882 0.1882];
            app.Label_11.Position = [60 607 105 26];
            app.Label_11.Text = '灭火时间：';

            % Create Label_12
            app.Label_12 = uilabel(app.RightPanel);
            app.Label_12.FontName = 'Microsoft YaHei UI';
            app.Label_12.FontSize = 20;
            app.Label_12.FontWeight = 'bold';
            app.Label_12.FontColor = [0.1882 0.1882 0.1882];
            app.Label_12.Position = [60 568 105 26];
            app.Label_12.Text = '烧毁面积：';

            % Create Label_13
            app.Label_13 = uilabel(app.RightPanel);
            app.Label_13.HorizontalAlignment = 'right';
            app.Label_13.FontName = 'Microsoft YaHei UI';
            app.Label_13.FontSize = 20;
            app.Label_13.FontWeight = 'bold';
            app.Label_13.FontColor = [0.1882 0.1882 0.1882];
            app.Label_13.Position = [565 568 85 26];
            app.Label_13.Text = '烧毁损失';

            % Create Label_14
            app.Label_14 = uilabel(app.RightPanel);
            app.Label_14.FontName = 'Microsoft YaHei UI';
            app.Label_14.FontSize = 20;
            app.Label_14.FontWeight = 'bold';
            app.Label_14.FontColor = [0.1882 0.1882 0.1882];
            app.Label_14.Position = [317 568 85 26];
            app.Label_14.Text = '救援费用';

            % Create Label_15
            app.Label_15 = uilabel(app.RightPanel);
            app.Label_15.FontName = 'Microsoft YaHei UI';
            app.Label_15.FontSize = 20;
            app.Label_15.FontWeight = 'bold';
            app.Label_15.FontColor = [0.1882 0.1882 0.1882];
            app.Label_15.Position = [317 607 111 26];
            app.Label_15.Text = '总经济损失:';

            % Create outputTime
            app.outputTime = uilabel(app.RightPanel);
            app.outputTime.FontName = 'Microsoft YaHei UI';
            app.outputTime.FontSize = 20;
            app.outputTime.FontWeight = 'bold';
            app.outputTime.Position = [159 607 145 26];
            app.outputTime.Text = '';

            % Create outputArea
            app.outputArea = uilabel(app.RightPanel);
            app.outputArea.FontName = 'Microsoft YaHei UI';
            app.outputArea.FontSize = 20;
            app.outputArea.FontWeight = 'bold';
            app.outputArea.Position = [159 568 145 26];
            app.outputArea.Text = '';

            % Create outputCostTotal
            app.outputCostTotal = uilabel(app.RightPanel);
            app.outputCostTotal.FontName = 'Microsoft YaHei UI';
            app.outputCostTotal.FontSize = 20;
            app.outputCostTotal.FontWeight = 'bold';
            app.outputCostTotal.Position = [427 607 164 26];
            app.outputCostTotal.Text = ' ';

            % Create outputCostFighter
            app.outputCostFighter = uilabel(app.RightPanel);
            app.outputCostFighter.FontName = 'Microsoft YaHei UI';
            app.outputCostFighter.FontSize = 20;
            app.outputCostFighter.FontWeight = 'bold';
            app.outputCostFighter.Position = [410 568 148 26];
            app.outputCostFighter.Text = '';

            % Create outputCostForest
            app.outputCostForest = uilabel(app.RightPanel);
            app.outputCostForest.FontName = 'Microsoft YaHei UI';
            app.outputCostForest.FontSize = 20;
            app.outputCostForest.FontWeight = 'bold';
            app.outputCostForest.Position = [660 568 154 26];
            app.outputCostForest.Text = '';

            % Create Label_27
            app.Label_27 = uilabel(app.RightPanel);
            app.Label_27.FontName = 'Microsoft YaHei UI';
            app.Label_27.FontSize = 24;
            app.Label_27.FontWeight = 'bold';
            app.Label_27.FontColor = [0.1882 0.1882 0.1882];
            app.Label_27.Position = [80 646 156 31];
            app.Label_27.Text = '仿真预测结果:';

            % Create Label_28
            app.Label_28 = uilabel(app.RightPanel);
            app.Label_28.HorizontalAlignment = 'center';
            app.Label_28.FontName = 'Microsoft YaHei UI';
            app.Label_28.FontSize = 22;
            app.Label_28.FontWeight = 'bold';
            app.Label_28.FontColor = [0.1882 0.1882 0.1882];
            app.Label_28.Position = [78 502 144 29];
            app.Label_28.Text = '森林实时火情:';

            % Create ForestLabel
            app.ForestLabel = uilabel(app.RightPanel);
            app.ForestLabel.FontName = 'Microsoft YaHei UI';
            app.ForestLabel.FontSize = 22;
            app.ForestLabel.FontWeight = 'bold';
            app.ForestLabel.FontColor = [0.1882 0.1882 0.1882];
            app.ForestLabel.Position = [226 502 132 29];
            app.ForestLabel.Text = '';

            % Create Label_30
            app.Label_30 = uilabel(app.RightPanel);
            app.Label_30.HorizontalAlignment = 'center';
            app.Label_30.FontName = 'Segoe UI Emoji';
            app.Label_30.FontSize = 30;
            app.Label_30.Position = [36 500 35 41];
            app.Label_30.Text = '🌳';

            % Create Label_31
            app.Label_31 = uilabel(app.RightPanel);
            app.Label_31.HorizontalAlignment = 'center';
            app.Label_31.FontName = 'Segoe UI Emoji';
            app.Label_31.FontSize = 30;
            app.Label_31.Position = [34 645 47 41];
            app.Label_31.Text = '⏲️';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = main

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end