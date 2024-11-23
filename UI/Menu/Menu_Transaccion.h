//Global variable for the definition of the header MENU_TRANSACCION_H
#ifndef MENU_TRANSACCION_H
#define MENU_TRANSACCION_H 1
#include "Menu_Empleado.h"

//Declaration of the Menu_Transaccion class
class Menu_Transaccion {

//Declaration of its public attributes and methods
    public:

//Builder's Declaration
    Menu_Transaccion(MariaDB* _conn, Menu_Empleado* _menu_empleado){
        conn = _conn;
        menu_empleado = _menu_empleado;
        }
    //Prototype declaration of the readOption method
    void readOption();

//Mainloop method declaration to display on-screen menu
    void mainloop(bool invalid_option = false){
    cls;
	std::cout << "========================TRANSACCION=========================" << std::endl;
    std::cout << "\n1. Hacer un prestamo." << std::endl;
    std::cout << "\n2. Devolver un libro." << std::endl;
    std::cout << "\n3. Ver devoluciones pendientes." << std::endl;
    std::cout << "\n0. Volver." << std::endl;
	std::cout << "\n============================================================" << std::endl;
    if(invalid_option)
        std::cout <<"Opcion invalida. Por favor, seleccione otra..."<<std::endl;
    std::cout << "Seleccione una opcion (0-3) > ";
    this->readOption();
    }
    
//hacerPrestamo method declaration
    void hacerPrestamo(){
        cls;
	    std::cout << "=========================PRESTAMOS==========================" << std::endl;
        std::cout << "\nIngrese el numero de cedula del empleado: > "; std::cin>>cedula_em;
        std::cout << "\nIngrese el numero de cedula del usuario: > "; std::cin>>cedula_us;
        std::cout << "\nIngrese el tutulo del libro: > "; std::cin.ignore(), std::cin.clear(); getline(std::cin, titulo_libro);
        output = conn->fetchQuery("CALL CrearPrestamo(\'" + cedula_em + "\', \'" + cedula_us + "\', \'" + titulo_libro + "\')");
        std::cin.clear();
        cls;
	    std::cout << "\n========================RESULTADO===========================" << std::endl;
        printQuery(output);
        do {
            std::cout <<"\n\nIngrese [0] para volver: > ";
            input = validation(input);
            if(input!=0)
		        std::cout <<"\nOpcion no valida. Por favor, intente de nuevo..."<<std::endl;
        } while (input !=0);
        this->mainloop();
    }
//devolverLibro method declaration
    void devolverLibro(){
        cls;
	    std::cout << "========================DEVOLUCIONES========================" << std::endl;
	    std::cout << "\nIngrese la cedula del usuario: > "; std::cin>>cedula_us;
        output = conn->fetchQuery("CALL DevolverLibro(\'" + cedula_us + "\')");
        cls;
	    std::cout << "\n========================RESULTADO===========================" << std::endl;
        printQuery(output);
        do {
            std::cout <<"\n\nIngrese [0] para volver: > ";
            input = validation(input);
            if(input!=0)
		        std::cout <<"\nOpcion no valida. Por favor, intente de nuevo..."<<std::endl;
        } while (input !=0);
        this->mainloop();
    }
//verDevolucionesPendientes method declaration
    void verDevolucionesPendientes(){
        cls;
	    std::cout << "=========================PENDIENTES=========================" << std::endl;
        output = conn->fetchQuery("CALL VerDevolucionesPendientes()");
        printQuery(output);
        do {
            std::cout <<"\n\nIngrese [0] para volver: > ";
            input = validation(input);
                if(input!=0)
		        std::cout <<"\nOpcion no valida. Por favor, intente de nuevo..."<<std::endl;
        } while (input !=0);
        this->mainloop();
    }

//Declaration of your private attributes and methods
    private:
    MariaDB* conn;
    Menu_Empleado* menu_empleado; 
    int input;
    dataframe_t output;
    std::string cedula_em;
    std::string cedula_us;
    std::string titulo_libro;

};

#endif