%%Limpiar variables y espacio de trabajo
clc;
clear;
%% ================== Parte 1: Cargar conjunto de datos  ===================
%  En este caso los datos de origen son definidos manualmente, sin embargo
% estos pueden ser le�dos a trav�s de un archivo .mat
 X = [4 -7 3; 1 4 -2; 10 7 9]

%% =============== Parte 2: Eliminar columnas con una varianza menor a n ===============
%  El programa recorrera todas las columnas de los datos, y calcular� la
%  varianza para cada una de las columnas, las columnas cuya varianza sea
%  menor al umbral establecido ser�n eliminadas
%  %leer o ingresar umbral 
    %n=input('Ingrese el valor para el umbral de la varianza: ');  
    n=0.2;
    X=normc(X);%normalizar datos
for i=size(X,2):-1:1
    %%Leer umbral de la varianza
    varianza=var(X);%calcular varianza de cada columna
    %%Ciclo condicional que elimina las columnas 
    if (varianza(i))<n
        X(:,i)=[]%Ac� se elimina la columna y se muestra la matriz resultante
        varianza(i)=[];                     
    end  
end
    