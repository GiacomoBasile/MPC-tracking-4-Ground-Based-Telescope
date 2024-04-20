function d = VonKarmanNoise(t, VonKarman)

VonKarman.N =10000;
VonKarman.f = (0.01:(10-0.01)/VonKarman.N:10-((10-0.01)/VonKarman.N))';
VonKarman.phi = rand(VonKarman.N,1);
VonKarman.df = 0.01;
VonKarman.v_mean = 3;
VonKarman.V = VonKarman.v_mean;
VonKarman.I = 0.15;
VonKarman.L = 3.2;
VonKarman.A = 10;
VonKarman.tau = 100;
VonKarman.alpha = 0.35;

v = cos((2*pi*VonKarman.f*t)+VonKarman.phi);


X = 1/(1+(2*sqrt(VonKarman.A)/VonKarman.v_mean).^(4/3));
Sv = (4*(VonKarman.I*VonKarman.v_mean)^2*(VonKarman.L/VonKarman.v_mean))/((1+((1.339*VonKarman.L)/VonKarman.v_mean).^2).^(5/6));
d = (sqrt(2*VonKarman.df*Sv*X^2)*4*100.^2/VonKarman.v_mean^2)*v;
d = sum(d);


end
