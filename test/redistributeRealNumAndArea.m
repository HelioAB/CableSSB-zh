function [RealNum,Area] = redistributeRealNumAndArea(Relation)
    Structures = Relation.Structures;
    LineList= Relation.LineList;
    RowIndex = Relation.RowIndex;
    ColumnIndex = Relation.ColumnIndex;
    X = Relation.X;

    len = length(X);
    RealNum = [];
    Area = [];

    for i=1:len
        lines = LineList{i};
        RealNum = [RealNum,[lines.Num]];
        row = RowIndex{i};
        col = ColumnIndex{i};
        for j=1:length(row)
            structure = Structures(row(j));
            AreaList = structure.Section.Area;
            Area = [Area,AreaList(col(j))];
        end
    end
end