%%Limpiar variables y espacio de trabajo
clc;
clear;
%% ================== Parte 1: Cargar conjunto de datos  ===================
%  En este caso los datos de origen son definidos manualmente, sin embargo
% estos pueden ser leídos a través de un archivo .mat
% load(matlab.mat)

X= [NaN NaN  5  3 NaN  5  7 NaN   9   2;
     8   9  NaN 1  4   5  6  3   NaN  5;
    NaN  4   9  8  7   2  4  1   NaN  3];

%% =============== Parte 2: Eliminar columnas con mas de n datos nulos ===============
%  El programa recorrera todas las columnas de los datos, y verificará
%  cuales campos son valores nulos, luego de esto sumará la cantidad de
%  valores nulos por columna,y eliminará los que superen el umbral
%  
    %%Leer o ingresar umbral
    %n=input('Ingrese el valor del umbral para los valores nulos: ');
    n=1;%
for i=size(X,2):-1:1
    
    %%Encontrar valores nulos en los datos de entrada
    TF = isnan(X);      
    %%Encontrar total de valores nulos x columna
    TF=sum(TF);
    %%Ciclo condicional que elimina las columnas con mas de n datos nulos
    if (TF(i))>n
        disp('La matriz resultante es'); %En caso de haber eliminado alguna columna se muestra la matriz
        X(:,i)=[]%mostrar como queda la matriz al eliminar la columna
        TF(i)=[];                     
    end  
end
        
