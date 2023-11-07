#ifndef NODE2_H
#define NODE2_H

#include <unistd.h>
#include <sstream>

struct Node {
  int numero;
  pid_t pid;
  pid_t padre;

  explicit Node(int numero_) :numero(numero_),pid(getpid()),padre(getppid()){
  }

  std::string toString() {
    std::stringstream aux;
    aux << "Proceso: " << numero << ", PID: " << pid << ", PID Padre: " << padre<<std::endl;
    return aux.str();
  }
};

typedef struct Node Nodo;

#endif // NODE2_H
