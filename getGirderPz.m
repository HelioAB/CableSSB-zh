function Pz_girder = getGirderPz(structure,X,Pz)
    % 输入按X排序的Pz，输出Structure可以直接使用的Pz
    girder_point = structure.findGirderPoint;
    X_girder_point = [girder_point.X];
    Pz_girder = zeros(1,length(X_girder_point));
    for i=1:length(X)
        index = abs(X(i)-X_girder_point) < 1e-5;
        Pz_girder(index) = Pz(i);
    end
end