classdef CableStayedSuspension_Bridge < Bridge
    properties
        SelfAnchored = false
    end
    methods
        build(obj)
        build_Parametrically(obj,options)
        solveHangerTopCoord(obj,hanger,Pz_Hanger) % 根据已知吊杆力，求解吊杆上端的空间位置（注意，固定竖向吊杆力时，不一定有解）
        % 合理成桥状态
        P_z = getAverageGirderWeight(obj,GirderList,HangerList,StayedCableList) % 计算所有梁总重平均分摊到所有Hanger和StayedCable上的力，输出标量
        [X,sorted_point] = getSortedGirderPointXCoord(obj,StrucutreList)
        bridge_findState = getNonCableBridge(obj,Pz_StayedCable,Pz_Hanger)
        
        
        [bridge_findState_final,U_final] = optimBendingStrainEnergy(obj)
        [Pz_girder,index]= getGirderPz(obj,structure,X,Pz)
        outputOptimMac(obj)
        output(obj)
        LoadCase = getLoadCases(obj,num_LoadCase,value_LoadCase)
        removeLoadCase(obj,num_LoadCase)
    end
    methods(Static,Hidden)
        test_solveHangerTopCoord()
        MSE = test_solveHangerTopCoord_ObjFunction(hanger,cable,P_girder_z,P_cable)
        [c,ceq] = test_solveHangerTopCoord_NonlinearControl(hanger,cable,P_girder_z,P_cable)
    end
end