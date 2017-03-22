% %%Limpiar variables y espacio de trabajo
 clc;
 clear;
% %% ================== Parte 1: Cargar archivo de datos  ===================
 %load('ex8data2.mat');
%% ================== Parte 2: Generar Nuevas Variables ===================
for i=1:size(X,2)
    for j=1:24:length(X)-24 %se realiza cada 24 muestras
        xmedian(j,i)=median(X(j:j+23,i));%calcular mediana
        xstd(j,i)=std(X(j:j+23,i));%desviación estándar
        xmin(j,i)=min(X(j:j+23,i));%calcular mínimos
        xmax(j,i)=max(X(j:j+23,i));%calcular máximos
     end  
end
%se eliminan las columnas vacias, para dejar unicamente las
%correspondientes a la reduccion de caracteristicas
for i=length(xmax):-1:1 
    if xmax(i,:)==zeros(1,size(xmax,2))
        xmedian(i,:)=[];
        xstd(i,:)=[];
        xmin(i,:)=[];
        xmax(i,:)=[];
    end
end
% %% ================== Parte 3: Guardar Variables ===================
% %se guardan las variables generadas, para tener un nuuevo conjunto de datos
x=[xmax xmedian xmin xstd]
