function [ X ] = PrepararDatos2( N )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
N(:,2)=[];
N(:,1)=[];
%% ================== Parte 2: Ordenar Variables ===================
%cada 6 variables que son el total que arroja nagios se concatenan, para
%formar un conjunto de datos
for i=1:8:length(N)-7
   X(i,:)=N(i:i+7,:)';
end
% %se elimnan las filas vacias 
for i=length(X):-1:1 
     if X(i,:)==zeros(1,size(X,2))
         X(i,:)=[];
     end
end

 X(1260:1361,9)= X(1259:1360,8);
 X(1259:1360,8)= X(1260:1361,1);
 X(1260:1361,1)= X(1260:1361,9);

X(:,9)=X(:,8); X(:,8)=X(:,1);X(:,1)=X(:,9);

X(:,9)=X(:,3);X(:,3)=X(:,2);X(:,2)=X(:,9);

X(:,9)=X(:,6);X(:,6)=X(:,3);X(:,3)=X(:,9);

X(:,9)=X(:,1);X(:,1)=X(:,7);X(:,7)=X(:,9);

X(:,9)=X(:,2);X(:,2)=X(:,4);X(:,4)=X(:,9);

X(:,9)=X(:,3);X(:,3)=X(:,6);X(:,6)=X(:,9);

X(:,9)=X(:,4);X(:,4)=X(:,7);X(:,7)=X(:,9);

X(:,9)=X(:,5);X(:,5)=X(:,6);X(:,6)=X(:,9);

X(:,9)=X(:,6);X(:,6)=X(:,7);X(:,7)=X(:,9);
X(:,9)=[];



