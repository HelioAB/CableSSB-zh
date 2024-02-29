function arrow_handle = plot(obj,options)
    arguments
        obj
        options.Color = 'm'
        options.Scale {mustBeNumeric} = 1 % 通过plot中的可选参数Scale控制箭头的长短，而不是quiver3函数自带的Scale属性
        options.Figure {mustBeA(options.Figure,'matlab.ui.Figure')} = figure
        options.Axis {mustBeA(options.Axis,'matlab.graphics.axis.Axes')} = axes
    end
%     for i=1:length(obj)
%         application = obj(i).Application;
%         len = length(application);
%         delta_X = zeros(1,len);
%         delta_Y = zeros(1,len);
%         delta_Z = zeros(1,len);
%         scale = options.Scale;
%             switch obj(i).Direction
%                 case 'X'
%                     for j=1:len
%                         delta_X(j) = scale*obj(i).Value{j};
%                     end
%                 case 'Y'
%                     for j=1:len
%                         delta_Y(j) = scale*obj(i).Value{j};
%                     end
%                 case 'Z'
%                     for j=1:len
%                         delta_Z(j) = scale*obj(i).Value{j};
%                     end
%             end
%         figure(options.Figure)
%         hold(options.Axis,'on')
%         arrow_handle = Load.getArrow(application,delta_X,delta_Y,delta_Z,options.Color,options.Figure,options.Axis);
%     end

        application = obj.AppliedPosition;
        len = length(application);
        delta_X = zeros(1,len);
        delta_Y = zeros(1,len);
        delta_Z = zeros(1,len);
        scale = options.Scale;
            switch obj.Direction
                case 'X'
                    for i=1:len
                        delta_X(i) = scale*obj.Value{i};
                    end
                case 'Y'
                    for i=1:len
                        delta_Y(i) = scale*obj.Value{i};
                    end
                case 'Z'
                    for i=1:len
                        delta_Z(i) = scale*obj.Value{i};
                    end
            end
        figure(options.Figure)
        hold(options.Axis,'on')
        arrow_handle = Load.getArrow(application,delta_X,delta_Y,delta_Z,options.Color,options.Figure,options.Axis);
end