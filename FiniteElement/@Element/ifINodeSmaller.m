function [index_INodeSmaller,index_JNodeSmaller,index_IJNodeSame] = ifINodeSmaller(obj,Direction)
    arguments
        obj
        Direction {mustBeMember(Direction,{'X','Y','Z'})}
    end
     % 将中点排序后的elements, 再根据Direction排序两个节点
    inodes = [obj.INode];
    jnodes = [obj.JNode];
    X_inodes = [inodes.X];
    Y_inodes = [inodes.Y];
    Z_inodes = [inodes.Z];
    X_jnodes = [jnodes.X];
    Y_jnodes = [jnodes.Y];
    Z_jnodes = [jnodes.Z];
    index_INodeSmaller = false(1,length(obj)); % XYZ较小的node
    index_JNodeSmaller = false(1,length(obj)); % XYZ较小的node
    index_IJNodeSame = false(1,length(obj));
    for i=1:length(obj)
        switch Direction
            case 'X'
                if X_inodes(i) < X_jnodes(i)
                    index_INodeSmaller(i) = true;
                elseif X_inodes(i) > X_jnodes(i)
                    index_JNodeSmaller(i) = true;
                elseif X_inodes(i) == X_jnodes(i)
                    index_IJNodeSame(i) = true;
                end
            case 'Y'
                if Y_inodes(i) < Y_jnodes(i)
                    index_INodeSmaller(i) = true;
                elseif Y_inodes(i) > Y_jnodes(i)
                    index_JNodeSmaller(i) = true;
                elseif Y_inodes(i) == Y_jnodes(i)
                    index_IJNodeSame(i) = true;
                end
            case 'Z'
                if Z_inodes(i) < Z_jnodes(i)
                    index_INodeSmaller(i) = true;
                elseif Z_inodes(i) > Z_jnodes(i)
                    index_JNodeSmaller(i) = true;
                elseif Z_inodes(i) == Z_jnodes(i)
                    index_IJNodeSame(i) = true;
                end
        end
    end
end