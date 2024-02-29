classdef DataRecord < handle
    properties
        Num = []
    end
    properties(Access = protected)
        flag_recorded = false
    end
    methods
        record(obj)
        unrecord(obj)
        edit(obj,PropertyName,ChangeTo)
        editObj(obj,PropertyName,ChangeTo)
        tf = isempty(obj)
        [uni_obj,obj2uni_index,uni2obj_index] = unique(obj)
        serialize(obj)

        [sorted_obj,index] = sort(obj,PropertyName,direction)
        [sorted_obj,index] = sortByReference(obj,reference,direction)

        [rep_num,rep_obj,rep_index] = findRepeat(obj)
        [exi_num,exi_obj,exi_index,nonexi_obj] = findExisting(obj)
        obj_list = findObjByNum(obj,Num)
        num_index = findIndexByNum(obj,Num)
        unrecorded = findUnrecord(obj)
        recorded = findRecord(obj)
        [recorded,unrecorded] = checkRecordState(obj)

        map = getMap(obj)
    end
    methods(Static)
        function data = Collection() 
            % 方法伪装成属性，完全等价于Static变量，且Collection可重载
            persistent Data
            if isempty(Data)
                Data = Collection();
            end
            data = Data;
        end
        function list = ObjList()
            
        end 
    end
end
