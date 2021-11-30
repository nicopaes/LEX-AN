#include <stdio.h>

int main()
{
    int X;
    printf("Entre com o valor de X \n");
    scanf("%d",&X);
    printf("Valor de X lido %d\n",X);
    int Z = 0;
    X++;
    X++;
    int i = X;
    while(i != 0)
    {

    X++;
    X++;
    i--;
    }
    X = 0;
    Z = X;
    printf("Resultado final %d\n",Z);
    return Z;
}
