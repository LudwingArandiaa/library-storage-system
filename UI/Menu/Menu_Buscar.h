//Global variable for the definition of the header MENU_BUSCAR_H
#ifndef MENU_BUSCAR_H
#define MENU_BUSCAR_H 1

//Declaration of the Menu_Buscar class
class Menu_Buscar {

//Declaration of its public attributes and methods
public:

//Builder's Declaration
Menu_Buscar(MariaDB* _conn, Menu_Usuario* _menu_usuario) {
	conn = _conn;
	menu_usuario = _menu_usuario;
	is_employee = false;
}

Menu_Buscar(MariaDB* _conn, Menu_Empleado* _menu_empleado) {
	conn = _conn;
	menu_empleado = _menu_empleado;
	is_employee = true;
}

//Prototype declaration of the readOption method
void readOption();

//Mainloop method declaration to display on-screen menu
void mainloop(bool invalid_option = false) {
	cls;
	std::cout << "===========================BUSCAR===========================" << std::endl;
	std::cout << "\n1. Buscar por autor." << std::endl;
	std::cout << "\n2. Buscar por fecha." << std::endl;
	std::cout << "\n3. Buscar por editorial." << std::endl;
	std::cout << "\n4. Buscar por genero." << std::endl;
	std::cout << "\n0. Volver." << std::endl;
	std::cout << "\n============================================================" << std::endl;
	if (invalid_option)
		std::cout << "Opcion invalida. Por favor, seleccione otra..." << std::endl;
	std::cout << "Seleccione una opcion (0-4): > ";
	this->readOption();
}

//buscarPorAutor method declaration
void buscarPorAutor() {
	cls;
	std::cout << "======================BUSCAR POR AUTOR======================" << std::endl;
	std::cout << "\nNombre o apellido del autor que buscas: > "; std::cin >> busqueda;
	output = conn->fetchQuery("CALL FiltrarPorAutor(\'" + busqueda + "\')");
	cls;
	std::cout << "\n=========================RESULTADO==========================" << std::endl;
	printQuery(output);
	do {
		std::cout << "\n\nIngresa [ 0 ] para volver... > ";
		input = validation(input);
		if(input!=0)
		std::cout <<"\nOpcion no valida. Por favor, intente de nuevo..."<<std::endl;
	} while (input != 0);
	this->mainloop();
}

//buscarPorFecha method declaration
void buscarPorFecha() {
	cls;
	std::cout << "======================BUSCAR POR FECHA======================" << std::endl;
	std::cout << "\nFecha que buscas: > "; 
	busqueda = date_validation(busqueda);
	output = conn->fetchQuery("CALL FiltrarPorFecha(\'" + busqueda + "\')");
	cls;
	std::cout << "\n=========================RESULTADO==========================" << std::endl;
	printQuery(output);
	do {
		std::cout << "\n\nIngresa [ 0 ] para volver... > ";
		input = validation(input);
		if(input!=0)
		std::cout <<"\nOpcion no valida. Por favor, intente de nuevo..."<<std::endl;
	} while (input != 0);
	this->mainloop();
}

//buscarPorEditorial method declaration
void buscarPorEditorial() {
	cls;
	std::cout << "====================BUSCAR POR EDITORIAL====================" << std::endl;
	std::cout << "\nEditorial que buscas: > "; std::cin.ignore(); getline(std::cin,busqueda);
	output = conn->fetchQuery("CALL FiltrarPorEditorial(\'" + busqueda + "\')");
	cls;
	std::cout << "\n=========================RESULTADO==========================" << std::endl;
	printQuery(output);
	do {
		std::cout << "\n\nIngresa [ 0 ] para volver... > ";
		input = validation(input);
		if(input!=0)
		std::cout <<"\nOpcion no valida. Por favor, intente de nuevo..."<<std::endl;
	} while (input != 0);
	this->mainloop();
}

//buscarPorGenero method declaration
void buscarPorGenero() {
	cls;
	std::cout << "=====================BUSCAR POR GENERO======================" << std::endl;
	std::cout << "\nGenero que buscas: > "; std::cin.ignore(); getline(std::cin,busqueda);
	output = conn->fetchQuery("CALL FiltrarPorGenero(\'" + busqueda + "\')");
	cls;
	std::cout << "\n=========================RESULTADO==========================" << std::endl;
	printQuery(output);
	do {
		std::cout << "\n\nIngresa [ 0 ] para volver... > ";
		input = validation(input);
		if(input!=0)
		std::cout <<"\nOpcion no valida. Por favor, intente de nuevo..."<<std::endl;
	} while (input != 0);
	this->mainloop();
}

//Declaration of your private attributes and methods
private:
	MariaDB* conn;
	dataframe_t output;
	std::string busqueda;
	int input;
	Menu_Usuario* menu_usuario;
	Menu_Empleado* menu_empleado;
	bool is_employee;
};

#endif