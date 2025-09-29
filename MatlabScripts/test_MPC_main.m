% for test_MPC.slx %


A_el = sysEl.A;
A_az = sysAz.A;

B_el = sysEl.B;
B_az = sysAz.B;

C_el = sysEl.C;
C_az = sysAz.C;

APel = [0, C_el; zeros(size(A_el,1),1), A_el];
APaz = [0, C_az; zeros(size(A_az,1),1), A_az];
At = blkdiag(APel, APaz);

BPel = [0; B_el];
BPaz = [0; B_az];
Bt = blkdiag(BPel, BPaz);

CPel = blkdiag(1,C_el);
CPaz = blkdiag(1,C_az);
Ct = blkdiag(CPel, CPaz);

Dt = zeros(size(Ct,1),size(Bt,2));