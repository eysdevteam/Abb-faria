%%Reinicializar variables
clc;
clear;
%% ================== Parte 1: Cargar conjunto de datos  ===================
%  En este caso los datos de origen son definidos manualmente, sin embargo
% estos pueden ser leídos a través de un archivo .mat
% load(matlab.mat)
A= [0 0  5  3 0  5  7 0   9   2;
     8   9  0 1  4   5  6  3   0  5;
    0  4   9  8  7   2  4  1   0  3];
%% =============== Parte 2: Eliminar columnas con correlación mayor a n ===============
%  El programa recorrera todas las columnas de los datos, y calculará la
%  corrrelación de cada columna con todas las demás, las columnas con alta
%  correlación son eliminadas y solo se conserva una
%  
%%Leer o ingresar umbral correlación
     %n=input('Ingrese el valor para el umbral de la correlación: ');  
     n=0.8
%%Ciclo que elimina columnas correlacionados por encima del umbral   
for i=size(A,2):-1:1
        A=normc(A);%Normalizar datos
        B=A;%Copiar la matriz A
        %%Correlación de la columna i contra todas las demás columnas
        for j=size(A,2):-1:1
        corr(i,j)=corr2(A(:,i),A(:,j));%se compara la fila i con todas las j restantes 
        if (i~=j)&((corr(i,j)>n)|(corr(i,j)<-n))%el umbral se define tanto positivo como negativo
               disp('La matriz resultante es: ');
                B(:,j)=[]%Eliminar columnas en la matriz 
        end
        end
end