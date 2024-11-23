//Global variable for the definition of the header MENU_USUARIO_H
#ifndef MENU_USUARIO_H
#define MENU_USUARIO_H 1

#include "Menu_Libros.h"
#include "Menu_Buscar.h"

//Declaration of the Menu_Usuario class
class Menu_Usuario {

//Declaration of its public attributes and methods
public: 

//Builder's Declaration
Menu_Usuario(MariaDB *_conn) {
	conn = _conn;
	menu_libros = new Menu_Libros(conn, this);
	menu_buscar = new Menu_Buscar(conn, this);
}

//Mainloop method declaration
void mainloop(bool invalid_option);

//Declaration of the method to read the options entered by keyboard
void readOption() {
	input = validation(input);
	switch (input) {
		case 1:
			menu_libros->mainloop();
			break;
		case 2:
			menu_buscar->mainloop();
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
	Menu_Libros* menu_libros;
	Menu_Buscar* menu_buscar;
	int input;
};

#endif