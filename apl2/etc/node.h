#ifndef NODE_H
#define NODE_H

#include <sstream>
#include <unistd.h>

using namespace std;

struct Node
{
  char letter;
  pid_t pid;
  pid_t parent;

  explicit Node(char letter_)
  {
    letter = letter_;
    pid = getpid();
    parent = getppid();
  }

  std::string toString()
  {
    std::stringstream aux;
    aux << "Process: " << letter << ", PID: " << pid << ", Parent PID: " << parent;
    return aux.str();
  }
};

typedef struct Node Node;

#endif // NODE_H
