//Global variable for the definition of the header MENU_PENALIZACION_H
#ifndef MENU_PENALIZACION
#define MENU_PENALIZACION 1
#include "Menu_Empleado.h"

//Declaration of the Menu_Penalizacion class
class Menu_Penalizacion {

//Declaration of its public attributes and methods
public:

//Builder's Declaration
    Menu_Penalizacion(MariaDB* _conn, Menu_Empleado* _menu_empleado){
        conn = _conn;
        menu_empleado = _menu_empleado;

    }

    //Prototype declaration of the readOption method
    void readOption();
    
//Mainloop method declaration to display on-screen menu
    void mainloop(bool invalid_option = false){
        cls;
	    std::cout << "========================PENALIZACION========================" << std::endl;
        std::cout << "\n1.Quitar Penalizacion."<<std::endl;
        std::cout << "\n2.Ver todas las penalizaciones."<<std::endl;
        std::cout << "\n0.Volver."<<std::endl;
        std::cout <<"\n============================================================"<<std::endl;
        if (invalid_option)
            std::cout << "\nOpcion invalida. Por favor, seleccione otra..."<<std::endl;
        std::cout << "Seleccione una opcion (0-2) > ";
        this->readOption();
    }

//quitarPenalizacion method declaration
    void quitarPenalizacion(){
        cls;
	    std::cout << "===========================QUITAR===========================" << std::endl;
        std::cout << "Ingrese la cedula del usuario: > "; std::cin>>cedula_us;
        output = conn->fetchQuery("CALL QuitarPenalizacion (\'" + cedula_us + "\')");
        cls;
	    std::cout << "\n=========================RESULTADO==========================" << std::endl;
        printQuery(output);
        do{
            std::cout<< "\n\nIngrese [0] para volver: > ";
            input = validation(input);
            if(input!=0)
		        std::cout <<"\nOpcion no valida. Por favor, intente de nuevo..."<<std::endl;
        }while (input !=0);
        this->mainloop();
    }

//VerPenalizaciones method declaration
    void verPenalizaciones(){
        cls;
	    std::cout << "=======================PENALIZACIONES=======================" << std::endl;
        output = conn->fetchQuery("CALL VerPenalizaciones");
        printQuery(output);
        do{
            std::cout <<"Ingrese [0] para volver. > ";
            input = validation(input);
            if(input!=0)
		        std::cout <<"\nOpcion no valida. Por favor, intente de nuevo..."<<std::endl;
        }while (input !=0);
        this->mainloop();
    }


//Declaration of your private attributes and methods
private:
MariaDB* conn;
Menu_Empleado* menu_empleado;
int input;
dataframe_t output;
std::string cedula_us;

};
#endif
