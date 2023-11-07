#include <cstring>
#include <iostream>
#include <map>
#include <sys/wait.h>
#include <unistd.h>
#include <vector>
#include "node.h"

#define ERROR -1
#define CHILD  0
#define INITIAL_NODE 'A'
#define DEFAULT_SLEEP_TIME 10

using namespace std;

int GenerateChildNodes(map<char, vector<char>> &nodes_map, char current_letter, unsigned int sleep_time);

int main(int argc, const char *argv[])
{
  map<char, vector<char>> nodes_map =
  {
    {'A', {'B', 'C'}},
    {'B', {'D', 'E'}},
    {'C', {'F'}},
    {'E', {'G', 'H'}},
  };

  unsigned int sleep_time = DEFAULT_SLEEP_TIME;

  if (argc > 1)
  { 
    try
    {
      sleep_time = stoi(argv[1]);
    }
    catch(const invalid_argument& e)
    {
      cerr << "Invalid time passed as parameter, using default time (" << time 
      << " seconds)." << endl;
    }
  }

  return GenerateChildNodes(nodes_map, INITIAL_NODE, sleep_time);
}

int GenerateChildNodes(map<char, vector<char>> &nodes_map,
  char current_letter,
  unsigned int sleep_time)
{
  Node current = Node(current_letter);
  cout << current.toString() << endl;

  if (nodes_map.find(current.letter) == nodes_map.end())
  {
    sleep(sleep_time);
    cout << "Cerrando proceso: " << current.letter << endl;
    return EXIT_SUCCESS;
  }

  for (auto next_child: nodes_map[current.letter])
  {
    pid_t new_pid = fork();

    switch (new_pid)
    {
    case ERROR:
      cerr << "Error: " << strerror(errno) << endl;
      return EXIT_FAILURE;
      break;
    
    case CHILD:
      return GenerateChildNodes(nodes_map, next_child, sleep_time);
      break;

    default: // Parent case
      break;
    }
  }

  for (auto next_child: nodes_map[current.letter])
  {
    wait(NULL);
  }

  cout << "Cerrando proceso: " << current.letter << endl;
  return EXIT_SUCCESS;
}
