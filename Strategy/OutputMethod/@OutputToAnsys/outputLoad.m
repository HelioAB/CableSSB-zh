function output_str = outputLoad(obj,fileName,Map_outputedAppliedPosition)
    arguments
        obj
        fileName = 'defLoad.mac'
        Map_outputedAppliedPosition = containers.Map('KeyType','char','ValueType','any');
    end
    load_list = obj.OutputObj.LoadList;

    

    % 计数，用于注释中
    count_UniformLoad = 0;
    count_ConcentratedForce = 0;
    % 输出的APDL字符串
    output_str = '';
    for i=1:length(load_list)
        LoadObj = load_list{i};
        class_name = getClassNameWithoutPackage(LoadObj);
        Load_value = LoadObj.Value;
        Load_direction = LoadObj.Direction;
        Load_name = LoadObj.Name; % 写在注释中
        output_str = [output_str,sprintf('! Load Name: %s',Load_name),newline];

        switch class_name
            % 如果Load对象是UniformLoad类
            case 'UniformLoad'
                count_UniformLoad = count_UniformLoad+1;
                Load_line = LoadObj.AppliedPosition;
                for j=1:length(Load_line) % 遍历这个荷载中的每一个Line对象
                    % 预处理
                    applied_line_j = Load_line(j); % 第i个Line
                    applied_value_j = Load_value{j}; % 作用在第i个Line上的值，因为是uniform load, applied_value{i}为一个double类型的数
                    num_line = applied_line_j.Num;
                    [value_face1,value_face2,value_face3] = getLoadFaceByDirection(applied_line_j,Load_direction);
                    applied_value_j = convertValue(Map_outputedAppliedPosition,applied_line_j,Load_direction,applied_value_j);
                    % 输出apdl命令
                    output_str = [output_str,sprintf(['allsel $ lsel,s,,,%d $ esll,s',newline,...
                                                      'cm,Elem_selected,elem',newline],num_line)]; % 将line对应的elem组成组件
                    if j~=1
                        output_str = [output_str,sprintf('cmsel,a,%s,elem',['Elem_UniformLoad_',num2str(count_UniformLoad)]),newline];
                    end
                    output_str = [output_str,sprintf('cm,%s,elem',['Elem_UniformLoad_',num2str(count_UniformLoad)]),newline]; % 将均布荷载施加到line所对应的elem上
                    output_str = [output_str,sprintf(outputDistributedLoad('Elem_selected',1,value_face1*applied_value_j,value_face1*applied_value_j,0,0)),...
                                             sprintf(outputDistributedLoad('Elem_selected',2,value_face2*applied_value_j,value_face2*applied_value_j,0,0)),...
                                             sprintf(outputDistributedLoad('Elem_selected',3,value_face3*applied_value_j,value_face3*applied_value_j,0,0))];
                    % 记录已经记载
                end
            % 如果Load对象是ConcentratedForce类
            case 'ConcentratedForce'
                count_ConcentratedForce = count_ConcentratedForce+1;
                Load_point = LoadObj.AppliedPosition;
                for j=1:length(Load_point)
                    % 预处理
                    applied_point_j = Load_point(j); % 第i个Point
                    applied_value_j = Load_value{j}; % 作用在第i个Point上的值
                    num_point = applied_point_j.Num;
                    load_type = strcat('F',Load_direction);
                    applied_value_j = convertValue(Map_outputedAppliedPosition,applied_point_j,Load_direction,applied_value_j);
                    % 输出apdl命令
                    output_str = [output_str,sprintf('ksel,s,,,%d $ nslk,s $ ',num_point)]; % 将line对应的elem组成组件
%                     if j~=1
%                         output_str = [output_str,sprintf('cmsel,a,%s,node',['Node_ConcentratedForce_',num2str(count_ConcentratedForce)]),newline];
%                     end
%                     output_str = [output_str,sprintf('cm,%s,node',['Node_ConcentratedForce_',num2str(count_ConcentratedForce)]),newline]; % 将均布荷载施加到line所对应的elem上
                    output_str = [output_str,sprintf(outputConcentratedLoad(load_type,applied_value_j)),newline];

                end
        end
        output_str = [output_str,'allsel',newline,'!-----------------------------------------------------------------------------------------------',newline];                 
    end
    % 输出到defSection.mac
    obj.outputAPDL(output_str,fileName,'w')
end

function output_str = outputDistributedLoad(cm_elemt,key_loadface,value_i,value_j,offset_i,offset_j)
    if offset_j < 0 % num2str(-1) == '-1'; num2str(0.0)=='0'; num2str(1.1)=='1.1'
        offset_j = -1;
    end
    % 每一个Line，都要用一次sfbeam
    output_str = sprintf('sfbeam,%s,%d,pres,%e,%e,,,%e,%e \n',cm_elemt,key_loadface,value_i,value_j,offset_i,offset_j);
    % sfbeam,elem,lkey,Lab,ValI,ValJ,Val2I,Val2J,IOffst,JOffst
    % elem,施加面荷载的单元号,可为All或元件名。这里统一用元件名
    % lkey,荷载面号，缺省时为1
    % Lab,结构分析中为Pres
    % ValI,节点I的荷载数值
    % ValJ,节点J的荷载数值
    % Val2I,Val2J: 未启用
    % IOffset：ValI离开I节点的距离
    % JOffset：ValJ离开J节点的距离
    % 例子1：线性分布荷载： sfbeam,elem,1,pres,Q1,Q2
    % 例子2：局部线性分布荷载：sfbeam,elem,1,pres,Q1,Q2,,,A1,A2
    % 例子3：跨间集中力：sfbeam,elem,1,pres,P1,,,,A1,-1
    % 例子3中的JOffset必须设置为-1,才能表示集中力
end

function output_str = outputConcentratedLoad(load_type,load_value)
    % 每一个Point,都要用一次
    arguments
        load_type {mustBeMember(load_type,{'FX','FY','FZ','MX','MY','MZ'})}
        load_value {mustBeNumeric}
    end
    % 
    output_str = sprintf('f,all,%s,%e',load_type,load_value);
    % f,node,Lab,Value
    % node,节点编号，可为All或元件名。这里统一元件名
    % Lab,集中荷载标识符,选取FX,FY,FZ,MX,MY,MZ中的一个
    % Value,集中荷载值
end

function class_Obj =  getClassNameWithoutPackage(Obj)
    class_Obj_overall = class(Obj);
    splited_str = strsplit(class_Obj_overall,'.');
    class_Obj = splited_str{end};
end

function [value_face1,value_face2,value_face3] = getLoadFaceByDirection(line,load_vector)
    % 输入：
    % line: 单个Line对象
    % load_vector:荷载方向向量
    % 输出：
    % value_face1, value_face2, value_face3:
    %   根据Line对象的方向和荷载的方向，确定作用在Line的3个荷载面的大小。三个荷载面荷载组成的向量的模为1
    if ischar(load_vector)||isstring(load_vector)
        if strcmpi(load_vector,'X')
            load_vector = [1,0,0];
        elseif strcmpi(load_vector,'Y')
            load_vector = [0,1,0];
        elseif strcmpi(load_vector,'Z')
            load_vector = [0,0,1];
        elseif strcmpi(load_vector,'None')
            load_vector = [0,0,0];
        else
            error('如果输入的荷载方向是字符，那么请输入"X","Y","Z"中的一个')
        end
    elseif isnumeric(load_vector)
        if length(load_vector)==3
            load_vector = load_vector/norm(load_vector); % 归一化
        else
            error('如果输入的荷载方向是数值，那么请输入一个1*3的数值向量')
        end
    else
        error('荷载方向必须为字符"X","Y","Z"中的一个，或1*3的数值向量')
    end

    [dir_x,dir_y,dir_z] = line.getLocalCoordSystem;
    proj_load_x = dot(load_vector,dir_x)/norm(dir_x);
    proj_load_y = dot(load_vector,dir_y)/norm(dir_y);
    proj_load_z = dot(load_vector,dir_z)/norm(dir_z);

    value_face1 = -proj_load_z;% ansys中，face1正方向代表z负方向
    value_face2 = -proj_load_y;% ansys中，face2正方向代表y负方向
    value_face3 = proj_load_x;% ansys中，face3正方向代表x正方向
end

function value = convertValue(map,apply,direciton,value)
    % 如果遇到作用位置相同，且作用方向相同的荷载就：
    %   将该荷载的值叠加
    map_key = sprintf('%s_%d_%s',class(apply),apply.Num,direciton);
    if any(strcmp(keys(map),map_key)) % 如果在这个AlliedPositon上施加过荷载
        map(map_key) = map(map_key)+value;
    else
        map(map_key)= value;
    end
    value = map(map_key);
end
function [merged_AppliedPosition_list,merged_Value_list,merged_Name_list] = mergeAppliedPosition(load_list)
    % 输入：
    %   load_list: 同一种Load子类对象的对象组成的cell，cell中不能有任何不同类型的对象。
    % 输出：
    %   merged_AppliedPosition_list：merge后的作用位置。为1*3的cell，cell(1,1)为X方向的作用位置对象数组
    %   merged_Value_list：          merge后的作用值。为1*3的cell
    %   merged_Name_list：           merge后的名称。为1*3的cell
    % 融合作用位置：在Ansys中同一个作用位置只能施加一个荷载，如果重复施加荷载，后定义的荷载会取代先定义的荷载。因此，相同作用位置的荷载应该相加
    % 本函数使用于ConcentratedForce和UniformLoad这两种Load子类对象的输出。如果其他Load子类对象，应该修改Value相关的逻辑
    % 提取所有作用位置、Name、作用值在一个对象数组中
    Direction_list = cellfun(@(obj) {obj.Direction},load_list);
    AppliedPosition_list = cellfun(@(obj) {obj.AppliedPosition},load_list);
    Name_list = cellfun(@(obj) {obj.Name},load_list);
    Value_list = cellfun(@(obj) {obj.Value},load_list);

    merged_AppliedPosition_list = cell(1,3);
    merged_Name_list = cell(1,3);
    merged_Value_list = cell(1,3);
    direction= {'X','Y','Z'};
    for i=1:3
        dir = direction{i};
        index_dir = strcmp(Direction_list,dir);
        dir_AppliedPosition_list = AppliedPosition_list(index_dir);
        dir_Value_list = Value_list(index_dir);
        dir_Name_list = Name_list(index_dir);
    
        applied_position_list = [];
        value_list = [];
        name_list = {};
        for j=1:length(dir_AppliedPosition_list)
            applied_position = dir_AppliedPosition_list{j};
            applied_position_list = [applied_position_list,applied_position];% 对象数组，以方便使用unique成员方法
            value = cell2mat(dir_Value_list{j});
            value_list = [value_list,value];% 数值向量
            name_list(end+1:end+length(value)) = cellfun(@(x) dir_Name_list(j),cell(1,length(value))); % 等长度的名字
        end
        [unique_applied_position_list,obj2uni_index,uni2obj_index] = applied_position_list.unique;
        unique_value_list = zeros(1,length(unique_applied_position_list));
        unique_name_list = cell(1,length(unique_applied_position_list));
        for j=1:length(unique_applied_position_list)
            index_same = uni2obj_index == j; % 相同的applied_position在applied_position_list中的index
            unique_value_list(j) = sum(value_list(index_same));
            unique_name_list(j) = {name_list(index_same)};
        end
        merged_AppliedPosition_list{1,i} = unique_applied_position_list;
        merged_Value_list{1,i} = unique_value_list;
        merged_Name_list{1,i} = unique_name_list;
    end
end

function [uni_cell,cell2uni_index,uni2cell_index] = uniqueStringCell(cellA)
    len = length(cellA);
    uni_cell = {};
    cell2uni_index = [];
    uni2cell_index = zeros(1,len);
    index = false(1,len);
    for i=1:len
        if index(i)
            continue
        else
            index(i) = true;
        end
        uni_cell(end+1) = cellA(i);
        cell2uni_index(end+1) = i;
        for j=i:len
            if equalStringCell(cellA(i),cellA(j))
                index(j) = true;
                uni2cell_index(j) = length(cell2uni_index);
            end
        end
    end
end
function tf = equalStringCell(cellA,cellB)
    % 判断字符串cell中的每个cell是否是相同字符串
    lenA = length(cellA);
    lenB = length(cellB);
    if lenA==lenB
        index_equal = false(1,lenA);
        for i=1:lenA
            if strcmp(cellA{i},cellB{i})
                index_equal(i) = true;
            end
        end
        tf = all(index_equal);% cellA中的每一个字符串都与cellB相等，字符串cell才算相等
    else
        tf = false;
    end
end

