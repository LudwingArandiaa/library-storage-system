#ifndef LOGIN_H
#define LOGIN_H 1

#include "Tools/utilities.h"
#include "Connector/MariaDB.h"
#include "UI/Menu/Menu.h"
#include "UI/colors.h"

#include <chrono>
#include <thread>
//Prototype declaration
void login();
void reboot_login();
void welcome();
void print_delay();
void Salida();
void invalid();

//Function declaration to print on screen with delay
void print_delay(std::string texto, int tiempo){
    
    for (char letra : texto){
        std::cout.put(letra);
        std::cout.flush();
        std::this_thread::sleep_for(std::chrono::microseconds(tiempo));
    }
}

//Welcome function
void welcome(){
    cls;
    std::cout<<YELLOW"\t+=================================================================================+"<<std::endl;
    std::cout<<"\t|                             ,..........   ..........,                           |"<<std::endl;
    std::cout<<"\t|                         ,..,'          '.'          ',..,                       |"<<std::endl;
    std::cout<<"\t|                        ,' ,'            :            ', ',                      |"<<std::endl;
    std::cout<<"\t|                       ,' ,'             :             ', ',                     |"<<std::endl;
    std::cout<<"\t|                      ,' ,'              :              ', ',                    |"<<std::endl;
    std::cout<<"\t|                     ,' ,'............., : ,.............', ',                   |"<<std::endl;
    std::cout<<"\t|                    ,'  '............   '.'   ............'  ',                  |"<<std::endl;
    std::cout<<"\t|                     '''''''''''''''''';''';''''''''''''''''''                   |"<<std::endl;
    std::cout<<"\t|                                        '''                                      |"<<std::endl;
    std::cout<<"\t|   _____         _           _      _        _   _ _   _ _     _                 |"<<std::endl;
    std::cout<<"\t|  |     |___ ___| |_ ___ ___| |   _| |___   | |_|_| |_| |_|___| |_ ___ ___ ___   |"<<std::endl;
    std::cout<<"\t|  |   --| . |   |  _|  _| . | |  | . | -_|  | . | | . | | | . |  _| -_|  _| .'|  |"<<std::endl;
    std::cout<<"\t|  |_____|___|_|_|_| |_| |___|_|  |___|___|  |___|_|___|_|_|___|_| |___|___|__,|  |"<<std::endl;
    std::cout<<"\t|                                                                                 |"<<std::endl;
    std::cout<<"\t|                                                                                 |"<<std::endl;
    std::cout<<"\t+=================================================================================+"<<std::endl;
    std::cout<<"\n";
    
    //Printing the names of the group members
    print_delay("\t\t\t\t           Bachilleres:", 15000);
    std::cout<<"\n\n";
    print_delay("\t\t\t\t  Ludwing Arandia, C.I: 28.769.798;", 15000);
    std::cout<<"\n\n";
    print_delay("\t\t\t\t  Carlos Diaz, C.I: 28.742.413;", 15000);
    std::cout<<"\n\n";
    print_delay("\t\t\t\t  Carlos Romero, C.I: 30.401.488;", 15000);
    std::cout<<"\n\n";
    //Press Enter
    print_delay("\t\t\t\t  Pulse Enter para continuar...", 100000);
    std::cin.clear(); std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    

    //Call to the function that executes the login
    login();
}

//Declaration of the return to login function
void reboot_login(){

    login();
}

//Declaration of function to request session data
void get_login_details(std::string &username, std::string &password){
    cls;
    std::cout<<"\t----------------------------------------------------------------------------"<<std::endl;
    std::cout<<"\t\t\t\tIntroduzca su nombre de usuario: "<<std::endl; std::cin>>username;
    std::cout<<"\t----------------------------------------------------------------------------"<<std::endl;
    std::cout<<"\t\t\t\tIntroduzca su contrasena: "<<std::endl; std::cin>>password;
}

//Function declaration for logging
void login(){
    std::string username, password;
    
    get_login_details(username,password);
    MariaDB *conn = new MariaDB("localhost", username, password, "biblioteca", false);

    //Connection status check
    if (conn->isDisconnect()){
        cls;
        std::cout<<"\t\t\tLos datos ingresados son incorrectos, intente de nuevo..."<<std::endl;
        reboot_login();
    }
    else{
        cls;
        std::cout<<"\t\t\t\tConectando..."<<std::endl;

        //Addressing Menu Classes
        if (username == "cliente"){
            std::cout<<"Abre menu de usuario..."<<std::endl;
            Menu_Usuario* menu_usuario = new Menu_Usuario(conn);
            menu_usuario->mainloop();
        }
        else {
            Menu_Empleado* menu_empleado = new Menu_Empleado(conn);
            menu_empleado->mainloop();
        }
    } 
}


void Salida(){
    int input;
    std::cin.ignore();
    do {
    std::cout << "\t\t1.Salir del programa."<<std::endl;
    std::cout <<"\t\t0.Ir al inicio."<<std::endl;
    std::cout <<"\nIngrese una opcion [0-1] > ";
    input = validation(input);
    switch (input) {
        case 1:
            exit(1);
            break;
        case 0:
            std::cin.ignore();
            welcome();
            break;
        default:
            cls;
            invalid();
        }
    } while(input!=1);
}



void invalid() {
    std::cout <<"\t\tOpcion invalida, intente de nuevo...\n"<<std::endl;
    Salida();
}


void Menu_Usuario::cerrar_sesion() {
    conn->closeDatabase();
    cls;
    std::cout << "=====================SESION FINALIZADA======================\n\n";
    Salida();
}

void Menu_Empleado::cerrar_sesion() {
    conn->closeDatabase();
    cls;
    std::cout << "=====================SESION FINALIZADA======================\n\n";
    Salida();
}

#endif