#include "./node2.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <map>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <vector>

#define ERROR -1
#define CHILD 0
#define NODO_INICIAL 1
// #define DEFAULT_SLEEP_TIME 10
#define PROCESO_DAEMON 2

using namespace std;

int generarNodosHijos(map<int, vector<int>> &mapa_nodos, int numeroInicial);

int main(int argc, const char *argv[])
{
  map<int, vector<int>> mapa_nodos = {{
      {1, {2, 3, 4}},
      {2, {5}},
      {3, {6}},
      {4, {7, 8}},
      {6, {9}},
      {7, {10}},
      {9, {11}},
  }};

  if (argc > 1 && strcmp(argv[1], "-h") == 0)
  {
    cout << "Este proceso muestra los distintos tipos de proceso en ejecucion, "
            "para finalizar presione 12 veces enter"
         << endl;
    exit(EXIT_SUCCESS);
  }

  generarNodosHijos(mapa_nodos, NODO_INICIAL);

  return EXIT_SUCCESS;
}

int generarNodosHijos(map<int, vector<int>> &mapa_nodos, int numeroInicial)
{
  Nodo actual = Nodo(numeroInicial);
  sleep(2);

  cout << actual.toString() << endl;

  // condicion de cierre
  if (mapa_nodos.find(actual.numero) == mapa_nodos.end())
  {
    cout << "Cerrando proceso ultimo: " << actual.numero << endl;
    // sleep(10);
    getchar();
    return EXIT_SUCCESS;
  }

  for (auto proximoHijo : mapa_nodos[actual.numero])
  {
    pid_t nuevoPid;
    if (proximoHijo == PROCESO_DAEMON)
    {
      nuevoPid = fork();
      switch (nuevoPid)
      {
      case ERROR:
        cerr << "Error: " << strerror(errno) << endl;
        exit(EXIT_FAILURE);
        break;

      case CHILD:
      // si queres que el daemon no te muestre el output en pantalla cambia el 
      // segundo parametro de daemon un 1 a un 0
        daemon(0, 1);
        return generarNodosHijos(mapa_nodos, proximoHijo);
        // sleep(2);
        break;

      default:
        break;
      }
    }
    else
    {
      nuevoPid = fork();
      switch (nuevoPid)
      {
      case ERROR:
        cerr << "Error: " << strerror(errno) << endl;
        exit(EXIT_FAILURE);
        break;

      case CHILD:
        // sleep(2);
        return generarNodosHijos(mapa_nodos, proximoHijo);
        break;

      default:
        break;
      }
    }
  }

  for (auto proximoHijo : mapa_nodos[actual.numero])
  {
    wait(nullptr);
  }

  cout << "Cerrando proceso padre: " << actual.numero << endl;

  return EXIT_SUCCESS;
}
