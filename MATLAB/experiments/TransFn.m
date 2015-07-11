function [L] = TransFn(Power,Frame,speech)

    
    
    [A,B,C,D] = butter(Power,Frame);
    sos = ss2sos(A,B,C,D);
    [m,n] = size(sos)
    
    t=0:1:m;
    TransFun=zeros(m*2,n/2);
    Transfer=zeros(m/2);
    u=ceil(n/2)
    
    [p,l]=size(TransFun);
    length(TransFun(1)) 
    
    for i=1:1:m
        for h=1:1:n/2
        TransFun(i,h) = sos(h);
        end;
        for k=n/2+1:1:n
        TransFun(i+1,k-n/2) = sos(k);
        end
    end;
    for i=1:2:m;
        Transfer[i] = tf(TransFun(i),TransFun(i+1))
    end;
    s=1;
    for o=1:1:length(Transfer)
        s=s*Transfer[i];
    end;
    s
    time= transpose(1:1:length(speech));
    
    
    size(speech);
    size(time);
    L=lsim(s,speech,time);
    figure(6);
    plot(time,L);
   