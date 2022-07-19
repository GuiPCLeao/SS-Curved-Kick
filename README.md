## Breve descrição dos scripts:

1.	```matlab/ballEquation.m```: Script que equaciona a ODE da trajetória da bola
2.	```matlab/kickerAngSolver.m```: Script que chama ballEquation.m para resolver via ODE45 do matlab, e realiza as transformações de coordenadas esperadas
3.	```matlab/KickerAnguladoGolOlimpicoSimul.m```: Script usado para testar a rede neural gerando casos de teste e plotando eles
4.	```matlab/map2Disc.m```: Script que mapeia pontos do campo para o campo discretizado
5.	```matlab/discField.m```: Script que constrói o campo discretizado
6.	```matlab/datasetCreation.m```: Roda loops encadeados para gerar uma grande combinação de dados que serão usados para treinar a rede
7.	```matlab/NetMCValidation.m```: Roda uma simulação de Monte Carlo para validar a rede
8.	```matlab/netSolution.m```: Script que chama a rede neural, faz a predição e faz as transformações de coordenadas necessárias
9.	```matlab/obstacleAvoidance.m```: Script que chama a rede neural para gerar uma trajetória da bola capaz de evitar adversários no campo
10.	```matlab/rgb.m```: Script auxiliar para gerar vetores 1x3 de cores RGB para usar no matlab.
11.	 ```notebook/Exame_CT_213.ipynb```: Script python / google collab que chama os datasets da rede, cria a rede neural, faz o treinamento e exporta a rede treinada.
12.	```results/model.h5```: Rede treinada para a predição

Para criar um dataset, basta rodar o script datasetCreation com os parâmetros estabelecidos. Isso gerará um .csv ```TreinaPosicGeneva.csv``` usado no treinamento da rede. O treinamento é realizado no script ```notebook/Exame_CT_213.ipynb``` que usa o .csv para treinar a rede e exportar a rede já treinada, um arquivo ```model.h5```. 

Com o ```model.h5```, que já está presente na pasta, para observar a solução da rede basta rodar ```matlab/KickerAnguladoGolOlimpicoSimul.m``` para observar um vídeo de uma situação aleatória proposta para ser resolvida pela rede. Para ver o resultado de um grande número de simulações aleatórias via método de Monte Carlo basta rodar o Script ```matlab/NetMCValidation.m```.

Para observar o algoritmo de desviar de adversários, basta rodar o script obstacleAvoidance.m. Esse script povoa o campo aleatoriamente, então pode ser necessário rodar algumas vezes para encontrar um caso onde a bola desvia de um adversário.
