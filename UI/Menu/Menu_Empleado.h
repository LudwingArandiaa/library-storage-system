//Global variable for the definition of the header MENU_EMPLEADO_H
#ifndef MENU_EMPLEADO_H
#define MENU_EMPLEADO_H 1

#include "Menu_Transaccion.h"
#include "Menu_Penalizacion.h"

//Declaration of the Menu_Empleado class
class Menu_Empleado {


//Declaration of its public attributes and methods
public:

	//Método constructor del menú
	Menu_Empleado(MariaDB* _conn) {
		conn = _conn; //Obtención de la conexión al servidor de la base de datos
		menu_libros = new Menu_Libros(conn, this);
		menu_buscar = new Menu_Buscar(conn, this);
		menu_penalizacion = new Menu_Penalizacion(conn, this);
		menu_transaccion = new Menu_Transaccion(conn, this);
	}
	
	//Mainloop method declaration to display on-screen menu
	void mainloop(bool invalid_option);

//Declaration of the method to read the options entered by keyboard
	void readOption() {
		input = validation(input);
		switch (input) {
			case 1:
				menu_transaccion->mainloop();
				break;
			case 2:
				menu_libros->mainloop();
				break;
			case 3:
				menu_buscar->mainloop();
				break;
			case 4:
				menu_penalizacion->mainloop();
				break;
			case 0:
				this->cerrar_sesion();
				break;
			default:
				this->mainloop(true);
		}
	}

//Logout method prototype declaration
	void cerrar_sesion();

//Declaration of your private attributes and methods
private:
	MariaDB* conn; 
	Menu_Penalizacion* menu_penalizacion; 
	Menu_Transaccion* menu_transaccion;
	Menu_Libros* menu_libros; 
	Menu_Buscar* menu_buscar; 
	int input; 
};


#endif