function q=leo2tec(arquivo)

x=load(arquivo);
C1=floor(x);
C2=round((x-C1)*1000);
C1=C1/1000;

q=[C1 C2];
