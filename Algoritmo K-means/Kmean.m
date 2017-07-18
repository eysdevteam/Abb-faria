%%Limpiar variables y espacio de trabajo
clc;clear;close all;
%% ================== Parte 1: Cargar datos de excel  ===================
%datos exportados de nagios
M=xlsread('GLPI.xlsx');
[ X ] = PrepararDatos( M );

%% ============ Parte 1: Calcular número de clusters  ===========
E = evalclusters(X,'kmeans','silhouette','klist',[1:6]);
figure;
plot(E)
%% ============ Parte 2: Aplicar K-Means x defecto ===========
%Utiliza K-means++ para la inicialización de de los centroides
%y la distancia ecludiana cuadrada por defecto.
%DEFECTO--> % [idx,C] = kmeans(X,2);
    %idx es un vector que contiene el índice del cluster correspondiente.
%C es una matriz que contiene la ubicación final de los centroídes
%OPCIONAL-->
opts = statset('Display','final');
[idx,C] = kmeans(X,2,'Distance','sqeuclidean',...
    'Replicates',5,'Options',opts);
%Distance:En este caso la distancia se cálcula a través de la suma de
%diferencias absolutas por defecto se sua la distacia euclidiana
%Replicates: equivale al número de veces que se realiza el agrupamiento,
%donde se recalcula la posición del centroíde; por defecto es 1,Se obtiene
%las distancias, ya que en muchos casos se encuentra mínimos
%locales y no un mínimo global.
figure;
plot(X(idx==1,1),X(idx==1,5),'r.','MarkerSize',12)
hold on
plot(X(idx==2,1),X(idx==2,5),'b.','MarkerSize',12)
% cuando son tres clusters
% hold on
% plot((X(idx==3,1)), X(idx==3,2) ,'g.','MarkerSize',12)


plot(C(:,1),C(:,2),'kx',...
     'MarkerSize',15,'LineWidth',3)
legend('Cluster 1','Cluster 2','Centroids',...
       'Location','NW')
 % legend('Cluster 1','Cluster 2','Cluster 3','Centroids',...
%        'Location','NW')
title 'Cluster Assignments and Centroids'
hold off
%Se grafican los diferentes puntos de cada cluster, así como los centroides

%% ============ Parte 3: Evaluar rendimiento  ===========
%a través de este se definieron 2 clusters en la grafica se muestra cada
%uno de los dos clusters, de igual modo se indica de las muestras asignadas
%a estos clusters con que precision fueron asignadas a este.
figure
[silh,h] = silhouette(X,idx);
h = gca;
h.Children.EdgeColor = [.8 .8 1];
xlabel 'Silhouette Value';
ylabel 'Cluster';

%https://es.mathworks.com/help/stats/k-means-clustering.html
%https://es.mathworks.com/help/stats/silhouette.html
%https://es.mathworks.com/help/stats/kmeans.html#buefthh-3