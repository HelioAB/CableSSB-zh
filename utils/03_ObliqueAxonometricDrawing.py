# -*- coding: utf-8 -*-
import rhinoscriptsyntax as rs

# 选取线对象
all_objs = rs.AllObjects()
#all_objs = rs.GetObjects("选取物体")
# 新建参考点ReferencePoint
WorldOrigin = rs.AddPoint([0,0,0])
rs.AddLayer("ReferencePoint")
rs.ObjectLayer(WorldOrigin,"ReferencePoint")
# 新建世界xyz方向的单位向量
unit_X_Point = rs.AddPoint([1,0,0])
unit_Y_Point = rs.AddPoint([0,1,0])
unit_Z_Point = rs.AddPoint([0,0,1])
rs.ObjectLayer(unit_X_Point,"ReferencePoint")
rs.ObjectLayer(unit_Y_Point,"ReferencePoint")
rs.ObjectLayer(unit_Z_Point,"ReferencePoint")
unit_X_Vector = rs.VectorCreate(unit_X_Point,WorldOrigin)
unit_Y_Vector = rs.VectorCreate(unit_Y_Point,WorldOrigin)
unit_Z_Vector = rs.VectorCreate(unit_Z_Point,WorldOrigin)
# 设定Shear基点和参考点
Shear_Origin_Point = WorldOrigin
Shear_Reference_Point = unit_Y_Vector
# Y轴方向变为原来的0.5倍
rs.ScaleObjects(all_objs,Shear_Origin_Point,[1,0.5,1])
# 先沿着Y轴旋转45°
rotated_objs = rs.RotateObjects(all_objs,WorldOrigin,45,axis=unit_Y_Vector)
# Shear
sheared_objs = rs.ShearObjects(rotated_objs,Shear_Origin_Point,Shear_Reference_Point,45)
# 沿着Y轴旋转-45°
ObliqueAxonometric_objs = rs.RotateObjects(sheared_objs,WorldOrigin,-45,axis=unit_Y_Vector)
# Make2D拍平