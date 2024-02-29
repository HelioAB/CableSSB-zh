function [fig,ax] = plot(obj)
    fig = figure;
    ax = axes;
    obj.plotStructure(fig,ax);
    axis equal
    obj.plotCoupling(fig,ax);
    obj.plotContraint(fig,ax);
    obj.plotLoad(fig,ax,1e-5);
end