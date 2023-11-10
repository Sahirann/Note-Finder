classdef NoteFinder_v2_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        Dropdown          matlab.ui.Figure
        ALabel_2          matlab.ui.control.Label
        CLabel_3          matlab.ui.control.Label
        FLabel_2          matlab.ui.control.Label
        DLabel_2          matlab.ui.control.Label
        CLabel_2          matlab.ui.control.Label
        BLabel            matlab.ui.control.Label
        ALabel            matlab.ui.control.Label
        GLabel            matlab.ui.control.Label
        FLabel            matlab.ui.control.Label
        ELabel            matlab.ui.control.Label
        DLabel            matlab.ui.control.Label
        CLabel            matlab.ui.control.Label
        OctaveGauge       matlab.ui.control.LinearGauge
        OctaveGaugeLabel  matlab.ui.control.Label
        NoteGauge         matlab.ui.control.SemicircularGauge
        NoteGaugeLabel    matlab.ui.control.Label
        Prosign           matlab.ui.control.Lamp
        FinishSign        matlab.ui.control.Lamp
        StartButton       matlab.ui.control.Button
        NoteFinderLabel   matlab.ui.control.Label
        GraphFFT          matlab.ui.control.UIAxes
        GraphTime         matlab.ui.control.UIAxes
    end

    
  properties (Access = private)
        NoteIndex = 0;
        plotPause = true;
        RecordLength = 40;
        frequencies = [16.35 17.32 18.35 19.45 20.6 21.83 23.12 24.5 25.96 27.5 29.14 30.87 32.7 34.65 36.71 38.89 41.2 43.65 46.25 49 51.91 55 58.27 61.74 65.41 69.3 73.42 77.78 82.41 87.31 92.5 98 103.83 110 116.54 123.47 130.81 138.59 146.83 155.56 164.81 174.61 185 196 207.65 220 233.08 246.94 261.63 277.18 293.66 311.13 329.63 349.23 369.99 392 415.3 440 466.16 493.88 523.25 554.37 587.33 622.25 659.25 698.46 739.99 783.99 830.61 880 932.33 987.77 1046.5 1108.73 1174.66 1244.51 1318.51 1396.91 1479.98 1567.98 1661.22 1760 1864.66 1975.53 2093 2217.46 2349.32 2489.02 2637.02 2793.83 2959.96 3135.96 3322.44 3520 3729.31 3951.07 4186.01 4434.92 4698.63 4978.03 5274.04 5587.65 5919.91 6271.93 6644.88 7040 7458.62 7902.13];
        notes = ["C0" "C#0" "D0" "D#0" "E0" "F0" "F#0" "G0" "G#0" "A0" "A#0" "B0" "C1" "C#1" "D1" "D#1" "E1" "F1" "F#1" "G1" "G#1" "A1" "A#1" "B1" "C2" "C#2" "D2" "D#2" "E2" "F2" "F#2" "G2" "G#2" "A2" "A#2" "B2" "C3" "C#3" "D3" "D#3" "E3" "F3" "F#3" "G3" "G#3" "A3" "A#3" "B3" "C4" "C#4" "D4" "D#4" "E4" "F4" "F#4" "G4" "G#4" "A4" "A#4" "B4" "C5" "C#5" "D5" "D#5" "E5" "F5" "F#5" "G5" "G#5" "A5" "A#5" "B5" "C6" "C#6" "D6" "D#6" "E6" "F6" "F#6" "G6" "G#6" "A6" "A#6" "B6" "C7" "C#7" "D7" "D#7" "E7" "F7" "F#7" "G7" "G#7" "A7" "A#7" "B7" "C8" "C#8" "D8" "D#8" "E8" "F8" "F#8" "G8" "G#8" "A8" "A#8" "B8"];
        octave = [0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 3 3 4 4 4 4 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6 6 6 6 7 7 7 7 7 7 7 7 7 7 7 7 8 8 8 8 8 8 8 8 8 8 8 8 9 9 9 9 9 9 9 9 9 9 9 9]
  end

  methods (Access = private)

        function plotAudio(app)

            while ~app.plotPause

                try
                    datalength = app.RecordLength/1000;                
                    audio = (app.getData());
                    Tscale = linspace(0,datalength,length(audio));
                    plot(app.GraphTime,Tscale,audio);
                    
                    
                    Fs = 8000;

                    Y = fft(audio);
                    L = length(audio);
                    P2 = abs(Y/L);
                    P1 = P2(1:L/2+1);
                    P1(2:end-1) = 2*P1(2:end-1);
                
                    % Create the frequency axis in Hz
                    f = Fs * (0:(L/2)) / L;
                
                    % Plot the FFT result on the UIAxes
                    plot(app.GraphFFT, f(10:length(f)), P1(10:length(f)));

                
                    app.updateDetectedNote(f,P1);

        
    
                   
                catch
                    beep;
                    app.stopPlot();
                end

            end
        end

        function updateDetectedNote(app,freqes,ampts)
            ampts(1:10) = 0;
            [~,index] = max(ampts);
            maxFreq = freqes(index);

            A = repmat(app.frequencies,[1 length(maxFreq)]);
            [~,closestIndex] = min(abs(A - maxFreq'));
            app.NoteIndex = closestIndex;
         
            app.NoteGaugeLabel.Text = app.notes(app.NoteIndex);
            app.NoteGauge.Value = mod(app.NoteIndex-1,12);
            app.OctaveGauge.Value = app.octave(app.NoteIndex);

            xline(app.GraphFFT,maxFreq,'--',string(maxFreq)+" Hz")

        end
        function stopPlot(app)

            app.StartButton.Text="Start";
            app.StartButton.BackgroundColor="0.69,0.69,0.92";
            app.Prosign.Enable = "on";
            app.FinishSign.Enable = "off";
            app.plotPause = true;
            

        end

        function Data = getData(app)
            port = serialport("COM3", 921600);
            data_list = zeros(1, 8000);
            i = 1;
            
            while i <= 8000
                data = readline(port);
                if str2double(data) < 3000 || i == 1
                    data_list(i) = str2double(data); % แปลงข้อมูลเป็นตัวเลข (หากมีความจำเป็น)
                else  
                    data_list(i) = data_list(i-1);
                end
                i = i + 1;
            end
            Data = data_list;
        end
  end


    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            if app.StartButton.Text == "Start"
                app.StartButton.Text="RECORDING...";
                app.StartButton.BackgroundColor="#f0f0f0";
                app.Prosign.Enable = "off";
                app.FinishSign.Enable = "on";
                app.plotPause = false;
                app.plotAudio();

            elseif app.StartButton.Text == "RECORDING..."
                app.stopPlot();
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create Dropdown and hide until all components are created
            app.Dropdown = uifigure('Visible', 'off');
            app.Dropdown.Color = [0.8118 0.902 0.8863];
            app.Dropdown.Position = [100 100 640 523];
            app.Dropdown.Name = 'MATLAB App';

            % Create GraphTime
            app.GraphTime = uiaxes(app.Dropdown);
            title(app.GraphTime, 'Time Domain')
            xlabel(app.GraphTime, 'Time')
            ylabel(app.GraphTime, 'Amplittude')
            zlabel(app.GraphTime, 'Z')
            app.GraphTime.Position = [322 267 300 221];

            % Create GraphFFT
            app.GraphFFT = uiaxes(app.Dropdown);
            title(app.GraphFFT, 'Frequency Domain (FFT)')
            xlabel(app.GraphFFT, 'Frequency')
            ylabel(app.GraphFFT, 'Amplitude')
            zlabel(app.GraphFFT, 'Z')
            app.GraphFFT.Position = [322 25 300 221];

            % Create NoteFinderLabel
            app.NoteFinderLabel = uilabel(app.Dropdown);
            app.NoteFinderLabel.FontName = 'Kristen ITC';
            app.NoteFinderLabel.FontSize = 36;
            app.NoteFinderLabel.FontWeight = 'bold';
            app.NoteFinderLabel.Position = [42 434 218 62];
            app.NoteFinderLabel.Text = 'Note Finder';

            % Create StartButton
            app.StartButton = uibutton(app.Dropdown, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [0.6902 0.6902 0.9216];
            app.StartButton.Position = [81 358 140 48];
            app.StartButton.Text = 'Start';

            % Create FinishSign
            app.FinishSign = uilamp(app.Dropdown);
            app.FinishSign.Position = [235 389 10 10];

            % Create Prosign
            app.Prosign = uilamp(app.Dropdown);
            app.Prosign.Position = [235 365 10 10];
            app.Prosign.Color = [1 0.4118 0.1608];

            % Create NoteGaugeLabel
            app.NoteGaugeLabel = uilabel(app.Dropdown);
            app.NoteGaugeLabel.HorizontalAlignment = 'center';
            app.NoteGaugeLabel.FontWeight = 'bold';
            app.NoteGaugeLabel.Position = [134 140 32 22];
            app.NoteGaugeLabel.Text = 'Note';

            % Create NoteGauge
            app.NoteGauge = uigauge(app.Dropdown, 'semicircular');
            app.NoteGauge.Limits = [0 12];
            app.NoteGauge.MajorTicks = [0 2.2 4.2 5.6 7.8 9.8 12];
            app.NoteGauge.MinorTicks = [1 3.2 6.7 8.8 11];
            app.NoteGauge.FontColor = [1 1 1];
            app.NoteGauge.Position = [29 177 241 131];

            % Create OctaveGaugeLabel
            app.OctaveGaugeLabel = uilabel(app.Dropdown);
            app.OctaveGaugeLabel.HorizontalAlignment = 'center';
            app.OctaveGaugeLabel.FontWeight = 'bold';
            app.OctaveGaugeLabel.Position = [127 40 45 22];
            app.OctaveGaugeLabel.Text = 'Octave';

            % Create OctaveGauge
            app.OctaveGauge = uigauge(app.Dropdown, 'linear');
            app.OctaveGauge.Limits = [0 8];
            app.OctaveGauge.MajorTicks = [0 1 2 3 4 5 6 7 8];
            app.OctaveGauge.MinorTicks = [0 1 2 3 4 5 6 7 8];
            app.OctaveGauge.Position = [28 77 243 41];

            % Create CLabel
            app.CLabel = uilabel(app.Dropdown);
            app.CLabel.FontSize = 14;
            app.CLabel.FontWeight = 'bold';
            app.CLabel.Position = [65 177 25 22];
            app.CLabel.Text = 'C';

            % Create DLabel
            app.DLabel = uilabel(app.Dropdown);
            app.DLabel.FontSize = 14;
            app.DLabel.FontWeight = 'bold';
            app.DLabel.Position = [81 223 25 22];
            app.DLabel.Text = 'D';

            % Create ELabel
            app.ELabel = uilabel(app.Dropdown);
            app.ELabel.FontSize = 14;
            app.ELabel.FontWeight = 'bold';
            app.ELabel.Position = [110 251 25 22];
            app.ELabel.Text = 'E';

            % Create FLabel
            app.FLabel = uilabel(app.Dropdown);
            app.FLabel.FontSize = 14;
            app.FLabel.FontWeight = 'bold';
            app.FLabel.Position = [137 258 25 22];
            app.FLabel.Text = 'F';

            % Create GLabel
            app.GLabel = uilabel(app.Dropdown);
            app.GLabel.FontSize = 14;
            app.GLabel.FontWeight = 'bold';
            app.GLabel.Position = [179 251 25 22];
            app.GLabel.Text = 'G';

            % Create ALabel
            app.ALabel = uilabel(app.Dropdown);
            app.ALabel.FontSize = 14;
            app.ALabel.FontWeight = 'bold';
            app.ALabel.Position = [211 224 25 22];
            app.ALabel.Text = 'A';

            % Create BLabel
            app.BLabel = uilabel(app.Dropdown);
            app.BLabel.FontSize = 14;
            app.BLabel.FontWeight = 'bold';
            app.BLabel.Position = [228 177 25 22];
            app.BLabel.Text = 'B';

            % Create CLabel_2
            app.CLabel_2 = uilabel(app.Dropdown);
            app.CLabel_2.Position = [65 201 25 22];
            app.CLabel_2.Text = 'C#';

            % Create DLabel_2
            app.DLabel_2 = uilabel(app.Dropdown);
            app.DLabel_2.Position = [92 240 25 22];
            app.DLabel_2.Text = 'D#';

            % Create FLabel_2
            app.FLabel_2 = uilabel(app.Dropdown);
            app.FLabel_2.Position = [161 258 25 22];
            app.FLabel_2.Text = 'F#';

            % Create CLabel_3
            app.CLabel_3 = uilabel(app.Dropdown);
            app.CLabel_3.Position = [196 236 25 22];
            app.CLabel_3.Text = 'C#';

            % Create ALabel_2
            app.ALabel_2 = uilabel(app.Dropdown);
            app.ALabel_2.Position = [224 201 25 22];
            app.ALabel_2.Text = 'A#';

            % Show the figure after all components are created
            app.Dropdown.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = NoteFinder_v2_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.Dropdown)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.Dropdown)
        end
    end
end