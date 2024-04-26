% 创建图形
figure;

% 绘制一些数据
x = 10:10:100;
y = x.^2;
plot(x, y);
%% 坐标轴
ax = gca;
%% 字体设置
FontName = 'Times New Roman + SimSun';
scale = 30;
units = 'points';
% axis大小
ax.Units = units;
Width_A4 = 21;
Width_LeftMargin_InWord = 3.17;
Width_RightMargin_InWord = 3.17;
MaxWidth_PictureInWord = Width_A4 - Width_LeftMargin_InWord - Width_RightMargin_InWord;
Width_Margin_Axis = 0.1;%
WidthDivision_Axis = 2;%
Width_PerAxis = MaxWidth_PictureInWord/WidthDivision_Axis;
ax.OuterPosition = scale*[Width_Margin_Axis,Width_Margin_Axis,Width_PerAxis-Width_Margin_Axis,Width_PerAxis-Width_Margin_Axis];
ax.InnerPosition = scale*[]
% 字体大小
ax.FontUnits = units;
FontSize_5 = 0.37;
FontSize_Small5 = 0.32;
FontSize = scale*FontSize_Small5; % 根据画幅大小设置

% 坐标轴相关: 固定参数设置
ax.FontName = FontName;
ax.TickDir = 'out';
ax.XMinorTick = 'on'; % X轴次刻度开启
ax.XAxis.MinorTickValues = (ax.XAxis.TickValues(1:end-1) + ax.XAxis.TickValues(2:end))/2;
ax.YMinorTick = 'on';
ax.YAxis.MinorTickValues = (ax.YAxis.TickValues(1:end-1) + ax.YAxis.TickValues(2:end))/2;
ax.ZMinorTick = 'on';
ax.ZAxis.MinorTickValues = (ax.ZAxis.TickValues(1:end-1) + ax.ZAxis.TickValues(2:end))/2;
ax.XAxis.Label.FontName = FontName;
ax.YAxis.Label.FontName = FontName;
ax.ZAxis.Label.FontName = FontName;
ax.Box = 'off';

% 调整刻度的长度
ax.TickLength = [0.01 0.005];
% 调整刻度的长度
ax.FontSize = FontSize;
% X坐标轴线宽
LineWidth = 0.7;
ax.XAxis.LineWidth = LineWidth;
ax.YAxis.LineWidth = LineWidth;
ax.YAxis.LineWidth = LineWidth;
% Label
ax.XAxis.Label.String = 'X Axis风速(100m/s)';
ax.YAxis.Label.String = 'Y Axis';
ax.ZAxis.Label.String = 'Z Axis';
FontSize_Label = FontSize;
ax.XAxis.Label.FontSize = FontSize_Label;
ax.YAxis.Label.FontSize = FontSize_Label;
ax.ZAxis.Label.FontSize = FontSize_Label;

%% 标题
text_title = '标题Title';
t = title(ax,text_title);
t.FontName = FontName;
t.FontSize = FontSize;
box('off')


