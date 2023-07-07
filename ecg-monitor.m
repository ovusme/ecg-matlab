classdef ECG_MONITOR_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        TimeLimitModeButtonGroup      matlab.ui.container.ButtonGroup
        AutoButton_2                  matlab.ui.control.ToggleButton
        ManualButton                  matlab.ui.control.ToggleButton
        SignalLimitEditField          matlab.ui.control.NumericEditField
        SignalLimitEditFieldLabel     matlab.ui.control.Label
        InputPinDropDown              matlab.ui.control.DropDown
        InputPinDropDownLabel         matlab.ui.control.Label
        CONNECTButton                 matlab.ui.control.Button
        MeasurementTimesecondSpinner  matlab.ui.control.Spinner
        MeasurementTimesecondSpinnerLabel  matlab.ui.control.Label
        SaveDataButton                matlab.ui.control.Button
        ByMuhammetEminvLabel          matlab.ui.control.Label
        PortDropDown                  matlab.ui.control.DropDown
        PortDropDownLabel             matlab.ui.control.Label
        DeviceNameDropDown            matlab.ui.control.DropDown
        DeviceNameDropDownLabel       matlab.ui.control.Label
        StatusLamp                    matlab.ui.control.Lamp
        YGridSwitch                   matlab.ui.control.Switch
        YGridSwitchLabel              matlab.ui.control.Label
        XGridSwitch                   matlab.ui.control.Switch
        XGridSwitchLabel              matlab.ui.control.Label
        STOPButton                    matlab.ui.control.Button
        LineWidthSpinner              matlab.ui.control.Spinner
        LineWidthSpinnerLabel         matlab.ui.control.Label
        SETTINGSLabel                 matlab.ui.control.Label
        RUNButton                     matlab.ui.control.Button
        LineStyleDropDown             matlab.ui.control.DropDown
        LineStyleDropDownLabel        matlab.ui.control.Label
        COLORDropDown                 matlab.ui.control.DropDown
        COLORDropDownLabel            matlab.ui.control.Label
        CLEARButton                   matlab.ui.control.Button
        HeartRateEditField            matlab.ui.control.NumericEditField
        HeartRateEditFieldLabel       matlab.ui.control.Label
        UIAxes                        matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        
        readstatus;
        gcolor = [];            
        glinewidth;
        glinestyle;
        xgridstat;
        ygridstat;
        heartrate;
        time=[];
        data=[];
        a;
        connectionstat;
        inputpin;
        signalLimit;
      

    end

    
    
    methods (Access = private)
        
        function graphsettings(app)

            switch (app.COLORDropDown.Value)
                case 'RED' 
                    app.gcolor = [1,0,0];
                case 'BLUE'
                    app.gcolor = [0,0,1];
                case 'BLACK'
                    app.gcolor = [0 0 0];
                otherwise
                    app.gcolor =[0.5 0.5 0.5];
            end
            
            switch (app.LineStyleDropDown.Value)
                case 'Solid' 
                    app.glinestyle = "-";
                case 'Dash-dotted'
                    app.glinestyle = "-.";
                case 'Dashed'
                    app.glinestyle = "--"; 
                otherwise
                    app.glinestyle = "-";
            end
          
           % setting gridmode

            if(app.XGridSwitch.Value == "On")
                app.UIAxes.XGrid = 'on';
            else
                app.UIAxes.XGrid = 'off';
            end

            if(app.YGridSwitch.Value == "On")
                app.UIAxes.YGrid = 'on';
            else
                app.UIAxes.YGrid = 'off';
            end
         % setting linewidth
            app.glinewidth = app.LineWidthSpinner.Value; 
        end
        
        function  toolboxenablecont(app,enable)
                 % Run steatment
            if (enable)
            app.RUNButton.Enable  = false;
            app.MeasurementTimesecondSpinner.Enable = false;
            app.STOPButton.Enable = true;
            app.CLEARButton.Enable = false;
            app.SaveDataButton.Enable = false;
            app.StatusLamp.Color = 'yellow';
            app.COLORDropDown.Enable = false;
            app.LineStyleDropDown.Enable = false;
            app.LineWidthSpinner.Enable = false;
            app.XGridSwitch.Enable = false;
            app.YGridSwitch.Enable = false;
            
            
                %   Stop Steatment 
            else
            app.RUNButton.Enable  = true;
            app.MeasurementTimesecondSpinner.Enable = true;
            app.STOPButton.Enable = false;
            app.CLEARButton.Enable = true;
            app.SaveDataButton.Enable = true;
            app.StatusLamp.Color = 'red';
            app.COLORDropDown.Enable = true;
            app.LineStyleDropDown.Enable = true;
            app.LineWidthSpinner.Enable = true;
            app.XGridSwitch.Enable = true;
            app.YGridSwitch.Enable = true;
            
            end

        end
        
        function  UIAxisMode(app,UImode)
            
            if(UImode =="manual")
                   app.UIAxes.YLimMode = 'manual';
                   app.UIAxes.YLimMode = 'manual'; 
                   app.UIAxes.YLim = [-5 app.SignalLimitEditField.Value+5];
                   app.UIAxes.XLim = [0 app.MeasurementTimesecondSpinner.Value];
            else
                   app.UIAxes.YLimMode = 'auto';
                   app.UIAxes.YLimMode = 'auto';
                   app.UIAxes.YLim = [-5 app.SignalLimitEditField.Value+5];
                   app.UIAxes.XLim = [0 app.MeasurementTimesecondSpinner.Value];
                   
            end    
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           app.STOPButton.Enable = false;
           app.RUNButton.Enable = false;
           UIAxisMode(app,"manual");
        end

        % Button pushed function: RUNButton
        function RUNButtonPushed(app, event)
            graphsettings(app);
            app.readstatus = true; 
            toolboxenablecont(app,true);
            app.InputPinDropDown.Enable= false;
            tic;
            i=0;
            while ( toc < app.MeasurementTimesecondSpinner.Value && app.readstatus)
               
               if(readDigitalPin(app.a,'D4')==0 && readDigitalPin(app.a,'D5')==0)
               i=i+1;
               app.time(i) = toc;
               app.data(i) = readVoltage(app.a,app.inputpin);
               plot(app.UIAxes,app.time,app.data,LineStyle=app.glinestyle,LineWidth=app.glinewidth,Color=app.gcolor);
               pause(0.001);  
               else
                   app.HeartRateEditField.Value = app.HeartRateEditField.Value + 1;
               end
            end
            toolboxenablecont(app,false);
            app.InputPinDropDown.Enable = true;
            
        end

        % Button pushed function: CLEARButton
        function CLEARButtonPushed(app, event)
            cla(app.UIAxes);
            msgbox("Cleaned","Warning","warn");
            app.time = [];
            app.data = [];
        end

        % Button pushed function: STOPButton
        function STOPButtonPushed(app, event)
            toolboxenablecont(app,false);
            app.readstatus = false;
         
        end

        % Button pushed function: SaveDataButton
        function SaveDataButtonPushed(app, event)
           
            if (isempty(app.data))
                msgbox("NO DATA","ERROR","error");
            else
                toolboxenablecont(app,true);
                writematrix(app.data,'ecgdata.xlsx');
                pause(1.5);
                toolboxenablecont(app,false);
                msgbox("SAVED DATA","OK");
            end
        end

        % Button pushed function: CONNECTButton
        function CONNECTButtonPushed(app, event)
             try  
              app.a= arduino(app.PortDropDown.Value,app.DeviceNameDropDown.Value);
              app.inputpin = app.InputPinDropDown.Value;
              app.RUNButton.Enable =true;
              app.CONNECTButton.Enable = false;
              app.CONNECTButton.Text = "ONLİNE";
              app.DeviceNameDropDown.Enable =false;
              app.PortDropDown.Enable =false;
            catch
                msgbox("Not found Device","ERROR","error");
                app.RUNButton.Enable = false;
             end
        end

        % Value changed function: InputPinDropDown
        function InputPinDropDownValueChanged(app, event)
            value = app.InputPinDropDown.Value;
            app.inputpin = value;
        end

        % Value changed function: SignalLimitEditField
        function SignalLimitEditFieldValueChanged(app, event)
            value = app.SignalLimitEditField.Value;
            app.UIAxes.YLim = [0 value];
        end

        % Value changed function: MeasurementTimesecondSpinner
        function MeasurementTimesecondSpinnerValueChanged(app, event)
            value = app.MeasurementTimesecondSpinner.Value;
            app.UIAxes.XLim = [0 value];
        end

        % Selection changed function: TimeLimitModeButtonGroup
        function TimeLimitModeButtonGroupSelectionChanged(app, event)
            selectedButton = app.TimeLimitModeButtonGroup.SelectedObject;
            
            if(selectedButton == app.ManualButton)
                UIAxisMode(app,"manual"); 
            else 
                UIAxisMode(app,"auto")
            end 
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [1 0.9961 0.9961];
            app.UIFigure.Position = [100 100 1186 764];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Resize = 'off';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Electrocardiography')
            xlabel(app.UIAxes, 'Time')
            ylabel(app.UIAxes, 'Signal')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.YLim = [-5 5];
            app.UIAxes.XColor = [0.149 0.149 0.149];
            app.UIAxes.YColor = [0 0 1];
            app.UIAxes.TitleHorizontalAlignment = 'left';
            app.UIAxes.Box = 'on';
            app.UIAxes.Tag = 'ecggraph';
            app.UIAxes.Position = [20 224 1147 495];

            % Create HeartRateEditFieldLabel
            app.HeartRateEditFieldLabel = uilabel(app.UIFigure);
            app.HeartRateEditFieldLabel.BackgroundColor = [1 1 1];
            app.HeartRateEditFieldLabel.HorizontalAlignment = 'right';
            app.HeartRateEditFieldLabel.FontSize = 15;
            app.HeartRateEditFieldLabel.FontColor = [0 0 1];
            app.HeartRateEditFieldLabel.Position = [1004 659 78 22];
            app.HeartRateEditFieldLabel.Text = 'Heart Rate';

            % Create HeartRateEditField
            app.HeartRateEditField = uieditfield(app.UIFigure, 'numeric');
            app.HeartRateEditField.Editable = 'off';
            app.HeartRateEditField.FontSize = 15;
            app.HeartRateEditField.FontColor = [0 0 1];
            app.HeartRateEditField.Position = [1097 659 55 22];

            % Create CLEARButton
            app.CLEARButton = uibutton(app.UIFigure, 'push');
            app.CLEARButton.ButtonPushedFcn = createCallbackFcn(app, @CLEARButtonPushed, true);
            app.CLEARButton.Tag = 'clearbuton';
            app.CLEARButton.Icon = 'cleaning.png';
            app.CLEARButton.BackgroundColor = [0.0588 1 1];
            app.CLEARButton.FontWeight = 'bold';
            app.CLEARButton.Position = [737 711 170 42];
            app.CLEARButton.Text = 'CLEAR';

            % Create COLORDropDownLabel
            app.COLORDropDownLabel = uilabel(app.UIFigure);
            app.COLORDropDownLabel.HorizontalAlignment = 'right';
            app.COLORDropDownLabel.FontSize = 15;
            app.COLORDropDownLabel.FontWeight = 'bold';
            app.COLORDropDownLabel.Position = [65 143 60 22];
            app.COLORDropDownLabel.Text = 'COLOR';

            % Create COLORDropDown
            app.COLORDropDown = uidropdown(app.UIFigure);
            app.COLORDropDown.Items = {'RED', 'BLUE', 'BLACK'};
            app.COLORDropDown.Tag = 'colorbox';
            app.COLORDropDown.FontSize = 15;
            app.COLORDropDown.FontWeight = 'bold';
            app.COLORDropDown.Position = [133 133 229 42];
            app.COLORDropDown.Value = 'RED';

            % Create LineStyleDropDownLabel
            app.LineStyleDropDownLabel = uilabel(app.UIFigure);
            app.LineStyleDropDownLabel.HorizontalAlignment = 'right';
            app.LineStyleDropDownLabel.FontSize = 15;
            app.LineStyleDropDownLabel.FontWeight = 'bold';
            app.LineStyleDropDownLabel.Position = [52 89 72 22];
            app.LineStyleDropDownLabel.Text = 'LineStyle';

            % Create LineStyleDropDown
            app.LineStyleDropDown = uidropdown(app.UIFigure);
            app.LineStyleDropDown.Items = {'Solid', 'Dash-dotted', 'Dashed'};
            app.LineStyleDropDown.Tag = 'markerbox';
            app.LineStyleDropDown.FontSize = 15;
            app.LineStyleDropDown.FontWeight = 'bold';
            app.LineStyleDropDown.Position = [131 77 231 42];
            app.LineStyleDropDown.Value = 'Solid';

            % Create RUNButton
            app.RUNButton = uibutton(app.UIFigure, 'push');
            app.RUNButton.ButtonPushedFcn = createCallbackFcn(app, @RUNButtonPushed, true);
            app.RUNButton.Tag = 'runbuton';
            app.RUNButton.Icon = 'heartecg.jpg';
            app.RUNButton.BackgroundColor = [1 1 1];
            app.RUNButton.FontSize = 18;
            app.RUNButton.FontWeight = 'bold';
            app.RUNButton.FontColor = [1 0 0];
            app.RUNButton.Position = [915 12 252 188];
            app.RUNButton.Text = 'R U N';

            % Create SETTINGSLabel
            app.SETTINGSLabel = uilabel(app.UIFigure);
            app.SETTINGSLabel.BackgroundColor = [1 0 0];
            app.SETTINGSLabel.HorizontalAlignment = 'center';
            app.SETTINGSLabel.FontSize = 18;
            app.SETTINGSLabel.FontWeight = 'bold';
            app.SETTINGSLabel.FontColor = [1 1 1];
            app.SETTINGSLabel.Position = [32 189 737 22];
            app.SETTINGSLabel.Text = {'S E T T I N G S'; ''};

            % Create LineWidthSpinnerLabel
            app.LineWidthSpinnerLabel = uilabel(app.UIFigure);
            app.LineWidthSpinnerLabel.HorizontalAlignment = 'right';
            app.LineWidthSpinnerLabel.FontSize = 15;
            app.LineWidthSpinnerLabel.FontWeight = 'bold';
            app.LineWidthSpinnerLabel.Position = [403 108 78 22];
            app.LineWidthSpinnerLabel.Text = 'LineWidth';

            % Create LineWidthSpinner
            app.LineWidthSpinner = uispinner(app.UIFigure);
            app.LineWidthSpinner.Step = 0.1;
            app.LineWidthSpinner.Limits = [1.5 2];
            app.LineWidthSpinner.HorizontalAlignment = 'center';
            app.LineWidthSpinner.FontSize = 15;
            app.LineWidthSpinner.FontWeight = 'bold';
            app.LineWidthSpinner.Position = [498 108 78 22];
            app.LineWidthSpinner.Value = 1.5;

            % Create STOPButton
            app.STOPButton = uibutton(app.UIFigure, 'push');
            app.STOPButton.ButtonPushedFcn = createCallbackFcn(app, @STOPButtonPushed, true);
            app.STOPButton.Tag = 'stopbtn';
            app.STOPButton.Icon = 'stopbutton.jpg';
            app.STOPButton.IconAlignment = 'top';
            app.STOPButton.BackgroundColor = [1 1 1];
            app.STOPButton.FontSize = 15;
            app.STOPButton.FontWeight = 'bold';
            app.STOPButton.Position = [788 12 110 188];
            app.STOPButton.Text = 'S T O P';

            % Create XGridSwitchLabel
            app.XGridSwitchLabel = uilabel(app.UIFigure);
            app.XGridSwitchLabel.HorizontalAlignment = 'center';
            app.XGridSwitchLabel.FontWeight = 'bold';
            app.XGridSwitchLabel.FontColor = [0 0 1];
            app.XGridSwitchLabel.Position = [220 28 50 22];
            app.XGridSwitchLabel.Text = 'XGrid';

            % Create XGridSwitch
            app.XGridSwitch = uiswitch(app.UIFigure, 'slider');
            app.XGridSwitch.FontColor = [0 0 1];
            app.XGridSwitch.Position = [295 29 45 20];

            % Create YGridSwitchLabel
            app.YGridSwitchLabel = uilabel(app.UIFigure);
            app.YGridSwitchLabel.HorizontalAlignment = 'center';
            app.YGridSwitchLabel.FontWeight = 'bold';
            app.YGridSwitchLabel.FontColor = [0 0 1];
            app.YGridSwitchLabel.Position = [65 28 38 22];
            app.YGridSwitchLabel.Text = 'YGrid';

            % Create YGridSwitch
            app.YGridSwitch = uiswitch(app.UIFigure, 'slider');
            app.YGridSwitch.FontColor = [0 0 1];
            app.YGridSwitch.Position = [138 29 43 19];

            % Create StatusLamp
            app.StatusLamp = uilamp(app.UIFigure);
            app.StatusLamp.Position = [1116 718 28 28];

            % Create DeviceNameDropDownLabel
            app.DeviceNameDropDownLabel = uilabel(app.UIFigure);
            app.DeviceNameDropDownLabel.HorizontalAlignment = 'right';
            app.DeviceNameDropDownLabel.FontWeight = 'bold';
            app.DeviceNameDropDownLabel.Position = [205 731 80 22];
            app.DeviceNameDropDownLabel.Text = 'Device Name';

            % Create DeviceNameDropDown
            app.DeviceNameDropDown = uidropdown(app.UIFigure);
            app.DeviceNameDropDown.Items = {'Uno', 'Micro', 'Nano3', 'Mega2560'};
            app.DeviceNameDropDown.FontWeight = 'bold';
            app.DeviceNameDropDown.Position = [302 731 86 22];
            app.DeviceNameDropDown.Value = 'Uno';

            % Create PortDropDownLabel
            app.PortDropDownLabel = uilabel(app.UIFigure);
            app.PortDropDownLabel.HorizontalAlignment = 'right';
            app.PortDropDownLabel.FontWeight = 'bold';
            app.PortDropDownLabel.Position = [397 731 40 22];
            app.PortDropDownLabel.Text = 'Port ';

            % Create PortDropDown
            app.PortDropDown = uidropdown(app.UIFigure);
            app.PortDropDown.Items = {'COM4', 'COM5', 'COM6'};
            app.PortDropDown.FontWeight = 'bold';
            app.PortDropDown.Position = [436 731 93 22];
            app.PortDropDown.Value = 'COM4';

            % Create ByMuhammetEminvLabel
            app.ByMuhammetEminvLabel = uilabel(app.UIFigure);
            app.ByMuhammetEminvLabel.FontName = 'Consolas';
            app.ByMuhammetEminvLabel.FontAngle = 'italic';
            app.ByMuhammetEminvLabel.Position = [1023 210 144 22];
            app.ByMuhammetEminvLabel.Text = 'By Muhammet Emin Övüş';

            % Create SaveDataButton
            app.SaveDataButton = uibutton(app.UIFigure, 'push');
            app.SaveDataButton.ButtonPushedFcn = createCallbackFcn(app, @SaveDataButtonPushed, true);
            app.SaveDataButton.Icon = 'savefile.png';
            app.SaveDataButton.FontWeight = 'bold';
            app.SaveDataButton.Position = [928 711 170 42];
            app.SaveDataButton.Text = 'Save Data';

            % Create MeasurementTimesecondSpinnerLabel
            app.MeasurementTimesecondSpinnerLabel = uilabel(app.UIFigure);
            app.MeasurementTimesecondSpinnerLabel.HorizontalAlignment = 'right';
            app.MeasurementTimesecondSpinnerLabel.FontSize = 15;
            app.MeasurementTimesecondSpinnerLabel.FontWeight = 'bold';
            app.MeasurementTimesecondSpinnerLabel.Position = [397 143 209 22];
            app.MeasurementTimesecondSpinnerLabel.Text = 'Measurement Time (second)';

            % Create MeasurementTimesecondSpinner
            app.MeasurementTimesecondSpinner = uispinner(app.UIFigure);
            app.MeasurementTimesecondSpinner.Limits = [30 90];
            app.MeasurementTimesecondSpinner.ValueChangedFcn = createCallbackFcn(app, @MeasurementTimesecondSpinnerValueChanged, true);
            app.MeasurementTimesecondSpinner.FontSize = 15;
            app.MeasurementTimesecondSpinner.FontWeight = 'bold';
            app.MeasurementTimesecondSpinner.Position = [621 143 82 22];
            app.MeasurementTimesecondSpinner.Value = 30;

            % Create CONNECTButton
            app.CONNECTButton = uibutton(app.UIFigure, 'push');
            app.CONNECTButton.ButtonPushedFcn = createCallbackFcn(app, @CONNECTButtonPushed, true);
            app.CONNECTButton.BackgroundColor = [0.6588 0.7216 0.8];
            app.CONNECTButton.FontSize = 15;
            app.CONNECTButton.FontWeight = 'bold';
            app.CONNECTButton.FontColor = [1 1 1];
            app.CONNECTButton.Position = [605 9 151 110];
            app.CONNECTButton.Text = 'CONNECT';

            % Create InputPinDropDownLabel
            app.InputPinDropDownLabel = uilabel(app.UIFigure);
            app.InputPinDropDownLabel.HorizontalAlignment = 'right';
            app.InputPinDropDownLabel.FontWeight = 'bold';
            app.InputPinDropDownLabel.Position = [531 731 57 22];
            app.InputPinDropDownLabel.Text = 'Input Pin';

            % Create InputPinDropDown
            app.InputPinDropDown = uidropdown(app.UIFigure);
            app.InputPinDropDown.Items = {'A0', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8'};
            app.InputPinDropDown.ValueChangedFcn = createCallbackFcn(app, @InputPinDropDownValueChanged, true);
            app.InputPinDropDown.FontWeight = 'bold';
            app.InputPinDropDown.Position = [603 731 100 22];
            app.InputPinDropDown.Value = 'A0';

            % Create SignalLimitEditFieldLabel
            app.SignalLimitEditFieldLabel = uilabel(app.UIFigure);
            app.SignalLimitEditFieldLabel.HorizontalAlignment = 'right';
            app.SignalLimitEditFieldLabel.FontSize = 13;
            app.SignalLimitEditFieldLabel.FontWeight = 'bold';
            app.SignalLimitEditFieldLabel.FontColor = [1 0 0];
            app.SignalLimitEditFieldLabel.Position = [1004 269 79 22];
            app.SignalLimitEditFieldLabel.Text = 'Signal Limit';

            % Create SignalLimitEditField
            app.SignalLimitEditField = uieditfield(app.UIFigure, 'numeric');
            app.SignalLimitEditField.ValueChangedFcn = createCallbackFcn(app, @SignalLimitEditFieldValueChanged, true);
            app.SignalLimitEditField.FontSize = 13;
            app.SignalLimitEditField.FontWeight = 'bold';
            app.SignalLimitEditField.FontColor = [1 0 0];
            app.SignalLimitEditField.Position = [1098 269 54 22];
            app.SignalLimitEditField.Value = 5;

            % Create TimeLimitModeButtonGroup
            app.TimeLimitModeButtonGroup = uibuttongroup(app.UIFigure);
            app.TimeLimitModeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @TimeLimitModeButtonGroupSelectionChanged, true);
            app.TimeLimitModeButtonGroup.TitlePosition = 'centertop';
            app.TimeLimitModeButtonGroup.Title = 'Time Limit Mode';
            app.TimeLimitModeButtonGroup.BackgroundColor = [1 1 1];
            app.TimeLimitModeButtonGroup.FontWeight = 'bold';
            app.TimeLimitModeButtonGroup.Position = [387 12 180 83];

            % Create ManualButton
            app.ManualButton = uitogglebutton(app.TimeLimitModeButtonGroup);
            app.ManualButton.Text = 'Manual';
            app.ManualButton.BackgroundColor = [0.3882 0.6 0.8314];
            app.ManualButton.FontColor = [1 1 1];
            app.ManualButton.Position = [16 30 150 25];
            app.ManualButton.Value = true;

            % Create AutoButton_2
            app.AutoButton_2 = uitogglebutton(app.TimeLimitModeButtonGroup);
            app.AutoButton_2.Text = 'Auto';
            app.AutoButton_2.BackgroundColor = [1 0 0];
            app.AutoButton_2.FontColor = [1 1 1];
            app.AutoButton_2.Position = [16 6 150 25];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ECG_MONITOR_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

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