% Find the angle between a pair of 2-vectors. Given components of vectors a and b, the angle theta
% is from a to b. That is, if a cross b is positive, then alpha is positive.
function theta = angle2d(ax,ay,bx,by)
% Magnitudes of the two vectors:
a = sqrt(ax.^2 + ay.^2);
b = sqrt(bx.^2 + by.^2);
% Simply invert the cross product:
theta = asin( ((ax .* by) - (ay .* bx))./(a .* b) );
