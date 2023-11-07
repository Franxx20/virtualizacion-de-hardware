CC = g++

OBJ_DIR = ./obj
BIN_DIR = ./bin
INC_DIR = ./inc
SRC_DIR = ./src

FLAGS = -g -Wall -I $(INC_DIR) -pthread -lrt 

TARGET = $(BIN_DIR)/ejercicio1
OBJS = $(OBJ_DIR)/ejercicio1.o 

$(TARGET) : $(OBJS)
	@mkdir -p $(BIN_DIR) 
	@$(CC) $(FLAGS) $(OBJS) -o $(TARGET) 



# esto sirve para compilar unicamente el archivo fuente que haya cambiado
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(OBJ_DIR) 
	@$(CC) -c -MD $(FLAGS) $< -o $@


# -c compila el archivo fuente pero no lo enlaza (osea no crea el ejecutable)
# sirve para no tener que recompilar todos los archivos fuente (cliente, servidor), si hay algun cambio, solo compila cliente o servidor
# -MD genera archivos de dependencia, sirve para checkear si hubo cambios en los .cpp ($(SRC_DIR)/%.cpp)
# 
# $< variable automatica: $< se reemplaza por $(SRC_DIR)/%.cpp
-include $(OJB_DIR)/*.d


.PHONY : clean
clean :
	@rm -r $(OBJ_DIR) $(BIN_DIR)