//Global variable for the definition of the header MENU_LIBROS_H
#ifndef MENU_LIBROS_H
#define MENU_LIBROS_H 1

//Declaration of the Menu_Libros class
class Menu_Libros {

//Declaration of its public attributes and methods
public:

//Builder's Declaration
Menu_Libros(MariaDB* _conn, Menu_Usuario* _menu_usuario) {
	conn = _conn;
	menu_usuario = _menu_usuario;
	is_employee = false;
}
Menu_Libros(MariaDB* _conn, Menu_Empleado* _menu_empleado) {
	conn = _conn;
	menu_empleado = _menu_empleado;
	is_employee = true;
}

//Mainloop method declaration to display on-screen menu
void mainloop() {
	cls; std::cout << "=====================LIBROS DISPONIBLES=====================\n";
	output = conn->fetchQuery("CALL LibrosDisponibles()");
	printQuery(output);
	std::cout << "\n============================================================\n" << std::endl;
	std::cout << "Ingresa [ 0 ] para volver... > ";
	this->readOption();
}

	//Prototype declaration of the readOption method
	void readOption();

//Declaration of your private attributes and methods
private:
	MariaDB* conn;
	Menu_Usuario* menu_usuario;
	Menu_Empleado* menu_empleado;
	dataframe_t output;
	int input;
	bool is_employee;
};

#endif