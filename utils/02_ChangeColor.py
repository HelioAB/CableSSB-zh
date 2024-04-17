# -*- coding: utf-8 -*-
import rhinoscriptsyntax as rs
#import xlrd
import random
from System.Drawing import Color

## 导入图层结构信息，将图层结构信息存储在字典中
#workbook = xlrd.open_workbook(r'C:\Users\Heli\Desktop\Coord_Points.xls')
#sheet_LayerStructure = workbook.sheet_by_name(r'Layer Structure')
#parent_child_dict = {}
#for row_num in range(sheet_LayerStructure.nrows):
#    row_values = sheet_LayerStructure.row_values(row_num)
#    parent_layer = row_values[0]
#    child_layers = row_values[1:]
#    child_layers = [child for child in child_layers if child]# 确保子图层名称不为空
#    parent_child_dict[parent_layer] = child_layers
    


# 函数定义：输入父图层名称和RGB值，以改变父图层中所有子图层的颜色
def ChangeLayerAttributionByParent(Name_ParentLayer,RGB,Name_LineType="Continuous",LineWidth=0,Recursion=False):
    # 选择父图层的所有子图层，并将子图层的名称保存在一个list中
#    if Name_ParentLayer in parent_child_dict:
#        Name_ChildLayer = parent_child_dict[Name_ParentLayer]
#    else:
#        Name_ChildLayer = rs.LayerChildren(Name_ParentLayer)
    Name_ChildLayer = rs.LayerChildren(Name_ParentLayer)
    # 改变所有子图层的信息
    color = Color.FromArgb(RGB[0],RGB[1],RGB[2])
    # 通过RGB值设置图层颜色
    rs.LayerColor(Name_ParentLayer,color)# 改变父图层颜色
    rs.LayerLinetype(Name_ParentLayer,Name_LineType)# 改变父图层的线型
    rs.LayerPrintWidth(Name_ParentLayer,LineWidth)# 改变父图层的线宽
    if Recursion:# 改变父图层下的所有图层（包括子图层的子图层）
        if rs.LayerChildCount(Name_ParentLayer)>0:
            ChildLayerList = rs.LayerChildren(Name_ParentLayer)
            for Name_ChildLayer in ChildLayerList:
                ChangeLayerAttributionByParent(Name_ChildLayer,RGB,Name_LineType,LineWidth,True)
    else:# 仅改变父图层下一层
        for layer in Name_ChildLayer:# 只改变下一级子图层属性
            rs.LayerColor(layer,color)
            rs.LayerLinetype(layer,Name_LineType)
            rs.LayerPrintWidth(layer,LineWidth)

def ChangeChildLayerInCurrentLayer(RGB,Name_LineType="Continuous",LineWidth=0,Recursion=False):
    Name_Layer = rs.CurrentLayer()
    ChangeLayerAttributionByParent(Name_Layer,RGB,Name_LineType,LineWidth,Recursion)

def findChildrenLayer(Name_ParentLayer, Name_ChildrenLayer):
    if rs.LayerChildCount(Name_ParentLayer) > 0:
        ChildLayerList = rs.LayerChildren(Name_ParentLayer)
        for Name_ChildLayer in ChildLayerList:
            splittedName_ChildLayer = Name_ChildLayer.split('::')
            if Name_ChildrenLayer in splittedName_ChildLayer:
                return Name_ChildLayer
            else:
                foundLayer = findChildrenLayer(Name_ChildLayer, Name_ChildrenLayer)
                if foundLayer:  # 如果在子图层中找到了匹配的图层，返回这个图层的名称
                    return foundLayer
    else:
        return None
        
def generate_vivid_rgb():
    components = [0, 0, 0]  # 初始化RGB分量
    high_component_index = random.randint(0, 2)  # 随机选择一个分量设置为255
    components[high_component_index] = 255
    # 为其它两个分量生成随机值
    for i in range(3):
        if i != high_component_index:
            components[i] = random.randint(0, 255)
    return tuple(components)
#配色1
#ChangeLayerAttributionByParent("Tower",[117,114,181],"Continuous",0)
#ChangeLayerAttributionByParent("Cable",[197,86,89],"Continuous",0)
#ChangeLayerAttributionByParent("Girder",[71,120,185],"Continuous",0)
#ChangeLayerAttributionByParent("RigidBeam",[203,180,123],"Continuous",0)
#ChangeLayerAttributionByParent("Hanger",[84,172,117],"Continuous",0)
#ChangeLayerAttributionByParent("StayedCable",[91,183,205],"Continuous",0)

#全黑色
#ChangeLayerAttributionByParent("Tower",[0,0,0],"Continuous",0)
#ChangeLayerAttributionByParent("Cable",[0,0,0],"Continuous",0)
#ChangeLayerAttributionByParent("Girder",[0,0,0],"Continuous",0)
#ChangeLayerAttributionByParent("RigidBeam",[0,0,0],"Continuous",0)
#ChangeLayerAttributionByParent("Hanger",[0,0,0],"Continuous",0)
#ChangeLayerAttributionByParent("StayedCable",[0,0,0],"Continuous",0)

ChangeLayerAttributionByParent("Bridge2D",[0,0,0],Name_LineType="Continuous",LineWidth=0,Recursion=True)

RGB = [[255,0,0],[0,255,0],[0,0,255],[255,255,0],[255,0,255],[0,255,255],
       [245,10,10],[10,245,10],[10,10,245],[245,245,10],[245,10,245],[10,245,245]]

for i in range(14):
    name = 'Girder_'+str(i+1)
    layer = findChildrenLayer('Bridge2D', name)
    random_rgb = random.choice(RGB)
    ChangeLayerAttributionByParent(layer,random_rgb,Name_LineType="Continuous",LineWidth=1,Recursion=True)
