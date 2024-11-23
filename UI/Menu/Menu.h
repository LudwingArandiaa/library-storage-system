//Global variable for the definition of the header MENU_H
#ifndef MENU_H
#define MENU_H 1

//Prototype declaration
class Menu_Usuario;
class Menu_Libros;
class Menu_Buscar;
class Menu_Empleado;
class Menu_Transaccion;
class Menu_Penalizacion;
#include "Menu_Usuario.h"
#include "Menu_Empleado.h"

//Mainloop method declaration to display on-screen menu 
void Menu_Usuario::mainloop(bool invalid_option = false) {
	cls;
	std::cout << "============================MENU============================" << std::endl;
	std::cout << "\n1. Ver libros disponibles." << std::endl;
	std::cout << "\n2. Buscar libros." << std::endl;
	std::cout << "\n0. Cerrar sesion." << std::endl;
	std::cout << "\n============================================================" << std::endl;
	if (invalid_option)
		std::cout << "Opcion invalida. Por favor selecciona otra..." << std::endl;
	std::cout << "Seleccione  una opcion (0-2): > ";
	this->readOption();
}


void Menu_Empleado::mainloop(bool invalid_option = false ) {
	cls;
	std::cout << "============================MENU============================" << std::endl;
	std::cout << "\n1. Transacciones." << std::endl;
	std::cout << "\n2. Ver libros disponibles." << std::endl;
	std::cout << "\n3. Buscar." << std::endl;
	std::cout << "\n4. Penalizaciones." << std::endl;
	std::cout << "\n0. Cerrar sesion." << std::endl;
	std::cout << "\n============================================================" << std::endl;
	if (invalid_option)
		std::cout << "Opcion invalida. Por favor selecciona otra..." << std::endl;
	std::cout << "Seleccione una opcion (0-4): > ";
	this->readOption();
}

//Declaration of the method to read the options entered by keyboard
void Menu_Libros::readOption() {
	do {
		std::cin.ignore();
		input = validation(input);
		if(input!=0)
		std::cout <<"\nOpcion no valida. Por favor, intente de nuevo..."<<std::endl;
		if (input == 0)
			if (!is_employee)
				menu_usuario->mainloop();
			else
				menu_empleado->mainloop();
	} while (input != 0);
}

void Menu_Buscar::readOption() {
	std::cin.ignore();
	input = validation(input);
		switch (input) {
			case 1:
				this->buscarPorAutor();
				break;
			case 2:
				this->buscarPorFecha();
				break;
			case 3:
				this->buscarPorEditorial();
				break;
			case 4:
				this->buscarPorGenero();
				break;
			case 0:
				if (!is_employee)
					menu_usuario->mainloop();
				else
					menu_empleado->mainloop();
				break;
				default:
				this->mainloop(true);
		}
}
	
    void Menu_Transaccion::readOption(){
        std::cin.ignore();
		input = validation(input);
        switch (input){
        	case 1:
				this->hacerPrestamo();
            	break;
			case 2:
				this->devolverLibro();
				break;
			case 3:
				this->verDevolucionesPendientes();
				break;
			case 0:
				menu_empleado->mainloop();
				break;
				default:
				this->mainloop(true);
        }
	}
	void Menu_Penalizacion::readOption(){
		std::cin.ignore();
		input = validation(input);
		switch (input)
		{
		case 1:
			this->quitarPenalizacion();
			break;
		case 2:
			this->verPenalizaciones();
			break;
		case 0:
			menu_empleado->mainloop();
			break;
		    default:
			this->mainloop(true);
		}
	}
#endif