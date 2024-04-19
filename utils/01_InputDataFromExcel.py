# -*- coding: utf-8 -*-
import rhinoscriptsyntax as rs
import xlrd

# 打开Excel文件
workbook = xlrd.open_workbook(r'C:\Users\Heli\Desktop\LayerInformation.xls')

# 选择工作表
sheet_Coord = workbook.sheet_by_name('Coordination')
sheet_LayerRange = workbook.sheet_by_name(r'Layer Range')
sheet_LayerStructure = workbook.sheet_by_name(r'Layer Structure')

# 初始化两个空列表来存储起点和终点坐标
Coord_StartPoints = []
Coord_EndPoints = []
for row_index in range(0, sheet_Coord .nrows):
    start_point = [sheet_Coord.cell_value(row_index, col_index) for col_index in range(0, 3)]
    end_point = [sheet_Coord.cell_value(row_index, col_index) for col_index in range(3, 6)]
    Coord_StartPoints.append(start_point)
    Coord_EndPoints.append(end_point)

# 将父图层名和子图层名的列表添加到字典中
parent_child_dict = {}
for row_num in range(sheet_LayerStructure .nrows):
    row_values = sheet_LayerStructure .row_values(row_num)
    parent_layer = row_values[0]
    child_layers = row_values[1:]
    child_layers = [child for child in child_layers if child]# 确保子图层名称不为空
    parent_child_dict[parent_layer] = child_layers

# 将图层对应范围的列表添加到字典中
layer_range_dict = {}
for row_num in range(sheet_LayerRange .nrows):
    row_values = sheet_LayerRange .row_values(row_num)
    name_layer = row_values[0]
    start_layers = int(row_values[1])
    end_layers = int(row_values[2])
    layer_range_dict[name_layer] = [start_layers,end_layers]
    

# 添加父图层
for key in parent_child_dict:
    rs.AddLayer(key)

# 添加子图层
for key in parent_child_dict:
    ChildLayers = parent_child_dict[key]
    for i in range(0,len(ChildLayers)):
        ChildLayer = ChildLayers[i]
        rs.AddLayer(ChildLayer,parent=key)

# 生成点对象
StartPoints = rs.AddPoints(Coord_StartPoints) # 起点的Geometry对象列表
EndPoints = rs.AddPoints(Coord_EndPoints) # 终点的Geometry对象列表
Num_Points = len(StartPoints)
rs.AddLayer("Point")
rs.ObjectLayer(StartPoints,"Point")
rs.ObjectLayer(EndPoints,"Point")

# 生成线对象，并存储线对象的位置
LineAndIndex = []
for i in range(0,Num_Points):
    StartPoint = StartPoints[i]
    EndPoint = EndPoints[i]
    if StartPoint:
        if EndPoint: 
            id_line = rs.AddLine(StartPoint, EndPoint) # 绘制线对象
    LineAndIndex.append([i,id_line])

# 改变线对象的图层
for key in layer_range_dict:
    range_start = int(layer_range_dict[key][0]-1)
    range_end = int(layer_range_dict[key][1]-1)
    id_lines = [row[1] for row in LineAndIndex[range_start:range_end+1]]
    for id in id_lines:
        rs.ObjectLayer(id,key) 