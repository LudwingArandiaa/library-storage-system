#ifndef UTILITIES_H
#define UTILITIES_H 1

#include <stdio.h>

#ifdef _WIN32
	#include <conio.h>
	
	#define cls system("cls")
#else
	#define cls system("clear")
	#define getch getchar
#endif

#include <iostream>
#include <limits>
#include <cmath>
#include <iomanip>
#include <vector>

#ifndef VALIDATION_H
#define VALIDATION_H 1

//NUMERIC VALIDATION IN STRING
bool isNumeric(const std::string &cadena) {
	for (char caracter : cadena) {
		if (!std::isdigit(caracter)) {
			return false;
		}
	}
	return true;
}

//DATE VALIDATION FUNCTION
std::string date_validation(std::string fecha) {
	int anio;
	do {
		do {
			std::cin >> fecha;
			if (!isNumeric(fecha))
				std::cout << "Ingresa un valor numerico... > "; //FIRST WE NEED TO KNOW IF THE VALUE IS A NUMERIC DATE
		} while (!isNumeric(fecha));
		std::stringstream ss(fecha);
		if (ss >> anio) {
			if (anio <= 0 or anio > 9999) //AFTER WE NEED TO EVALUATE IF THE NUMBER IS A VALID YEAR
				std::cout << "Ingresa un valor numerico de maximo 4 caracteres... > ";
		}
	} while (anio <= 0 or anio > 9999);
	return fecha; //FINALLY RETURN THE DATE
}

//VALIDATION INTEGER FUNCTION
double validation(int n) {
    while (!(std::cin >> n)) {
        std::cout << "Por favor, ingresar un valor numerico valido: > ";
        std::cin.clear(); std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }
    return n;
}

#endif

#ifndef TYPDEF_DATAFRAME
#define TYPDEF_DATAFRAME 1
//DEFINITION OF TYPEDEF DATAFRAME_T IS A VECTOR OF STRINGS VECTOR
typedef std::vector<std::vector<std::string>> dataframe_t;

//CONST DF_VOID IS A VOID DATAFRAME
const dataframe_t DF_VOID = {{"EMPTY"}};

#endif

#ifndef TRUNCATE_STRING
#define TRUNCATE_STRING 1

//FUNCTION FOR TRUNCATE THE TEXT
std::string truncate_string(std::string const text, std::size_t maxLength = 15) {
	//CREATE STRNG
	std::string truncated_text = text;

	//REMPLACE THE ORIGINAL TEXT FOR TRUNCATED STRING
	if (text.length() > maxLength) {
		truncated_text = text.substr(0, maxLength) + "...";
	}

	return truncated_text;
}

#endif

#ifndef PRINTER_DFMATRIX
#define PRINTER_DFMATRIX 1


//FUNCTION FOR SEE THE DETAILS OF ONE OF THE ROWS IN THE TABLE
void verDetalles(dataframe_t result, int paginas, int resto_paginas, int cantidad_registros, int pagina_actual) {
		int opcion;

	//WE DON'T NEED SELECT THE ROW IF WE HAVE ONLY ONE ROW
	if (cantidad_registros == 1) {
		cls;
		for (int i = 0; i < result[0].size(); i++) {
			std::cout << result[0][i] << ": " << result[1][i] << ".\n";
		}
	} else { //IN THE OTHER HAND

		//LIMITS DECLARATION AND DEFINITION
		int limite_inferior, limite_superior;
		limite_inferior = (pagina_actual - 1)*15 + 1;
		if (cantidad_registros > 15) 
			limite_superior = (pagina_actual == paginas ? (pagina_actual*15 - resto_paginas) : (pagina_actual*15));
		else
			limite_superior = cantidad_registros;

		std::cout << std::endl;

		do {
			std::cout << "Ingresa el numero del registro que deseas ver: > ";
			opcion = validation(opcion);

			//VALIDATION FOR THE SELECTED ROW
			if (opcion > limite_superior or opcion < limite_inferior)
				std::cout << "Elige un registro que se encuentre en la pagina actual." << std::endl;
		} while (opcion > limite_superior or opcion < limite_inferior);

		cls;
		//PRINT THE DETAILS IN SCREEN
		for (int i = 0; i < result[0].size(); i++) {
			std::cout << result[0][i] << ": " << result[opcion][i] << (result[0][i] == "Sinopsis" ? "\n" : ".\n");
		}
	}
	//ENTER FOR BACK
	std::cout << "Presiona enter para volver... > ";
	std::cin.get(); std::cin.clear(); std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

//PRINT QUERY FUNCTION
void printQuery(dataframe_t result) {
	//ONLY EXECUTE THE FUNCTION IF THE MATRIX IS NOT EMPTY
	if (!result.empty()) {
		//VAR DECLARATION AND DEFINITION
		dataframe_t original_vector = result;
		int n;
		int cantidad_registros = (result.size() - 1);
		int paginas = (int) ceil( (float) cantidad_registros / 15);
		int resto_paginas = cantidad_registros % 15;

		//LIMITS DECLARATION
		int limite_inferior;
		int limite_superior;


		//TRUNCATE FRAMES
		unsigned int num_fields = result[0].size();
		for (unsigned int j = 1; j < result.size(); j++) {
			for (unsigned int i = 0; i < num_fields; i++) {
				//THE SIZE OF THE TRUNCATE DEPENDS OF THE NUMBER OF FIELDS
				if (num_fields == 1)
					result[j][i] = result[j][i];
				else if (num_fields < 7)
					result[j][i] = truncate_string(result[j][i]);
				else
					result[j][i] = truncate_string(result[j][i], 11);
			}
		}


		//MAX_WIDTH VECTOR DECLARATION IN FUNCTION OF THE DATAFRAME SIZE
		std::vector<std::size_t> max_width(result[0].size());
		//CLEAR THE VECTOR
		for (int i = 0; i < max_width.size(); i++) {
			max_width[i] = 0;
		}
		//LOOP FOR FIND THE MAX WIDTH BY COLUMNS IN THE MATRIX
		for (int i = 0; i < result[0].size(); i++) {
			for (int j = 0; j < result.size(); j++) {
				if (result[j][i].size() > max_width[i]) {
					max_width[i] = result[j][i].size();
				}
			}
		}

		//LOOP FOR PRINT THE FIELDS BEFORE THE CONTENT
		for (int i = 1; i <= paginas; i++) {
			//SET NUMBER SPACING
			if (cantidad_registros > 1) std::cout << "   ";
			for (int j = 0; j < result[0].size(); j++) { //PRINT FIELDS
				std::cout << result[0][j] << std::setw(max_width[j] == result[0][j].size() ? max_width[j] - result[0][j].size() : max_width[j] - result[0][j].size() + 1) << std::left << " ";
				std::cout << "\t";
			}

			//LIMITS DEFINITION
			limite_inferior = (i - 1)*15 + 1;
			if (cantidad_registros > 15) 
				limite_superior = (i == paginas ? (i*15 - resto_paginas + 1) : (i*15 + 1));
			else
				limite_superior = cantidad_registros + 1;


			std::cout << std::endl;
			//PRINT THE MATRIX
			for (int j = limite_inferior; j < limite_superior; j++) {
				if (cantidad_registros > 1) std::cout << j << ". ";
				for (int k = 0; k < result[0].size(); k++) {
					//THE SPACE BEETWEEN COLUMNS IS THE MAX WIDTH OF THE COLUMN MINUS THE ACTUAL ELEMENT SIZE
					std::cout << result[j][k] << std::setw(max_width[k] == result[j][k].size() ? max_width[k] - result[j][k].size() : max_width[k] - result[j][k].size() + 1) << std::left << " ";
					std::cout << "\t";
				}
				std::cout << "\n";
			}
			std::cout << std::endl;

			//SET THE OPTION FOR CHANGE BETWEEN PAGES ON THE DATAFRAME
			if (num_fields != 1) {
				//IF IT IS IN A MIDDLE PAGE
				if (i > 1 and i < paginas) {
					do {
						std::cout << "Pag: " << i << ". Ingresa [2] para ver detalles, [1] para ver siguiente Pag. [0] para la anterior: > ";
						n = validation(n);
						if (n == 0)
							i = i - 2;
						else if (n == 2) {
							verDetalles(original_vector, paginas, resto_paginas, cantidad_registros, i);
							cls;
							i = i - 1;
						}
						else if (n != 0 and n != 1 and n != 2)
							std::cout << "Opcion invalida. ";
					} while (n != 0 and n != 1 and n != 2);
					cls;
				} //IF IT IS IN THE LAST PAGE
				else if (i == paginas and cantidad_registros > 15) {
					do {
						std::cout << "Pag: " << i << ". Ingresa [2] Para ver detalles, [1] para finalizar o [0] para ver la Pag. anterior: > ";
						n = validation(n);
						if (n == 0) {
							i = i - 2;
							cls;
						} else if (n == 2) {
							verDetalles(original_vector, paginas, resto_paginas, cantidad_registros, i);
							cls;
							i = i - 1;
						}
						else if (n != 0 and n != 1 and n != 2)
							std::cout << "Opcion invalida. ";
					} while (n != 0 and n != 1 and n != 2);
				} //IF THE DATAFRAME ONLY HAVE ONE PAGE
				else if (i == paginas and cantidad_registros <= 15) {
					do {
						std::cout << "Ingresa [2] Para ver detalles, [1] para finalizar: > ";
						n = validation(n);
						if (n == 2) {
							verDetalles(original_vector, paginas, resto_paginas, cantidad_registros, i);
							cls;
							i = i - 1;
						} else if (n != 1 and n != 2) {
							std::cout << "Opcion invalida. ";
						}
					} while (n != 1 and n != 2);
				} //IF IT IS THE FIRST PAGE
				else {
					do {
						std::cout << "Pag: " << i << ". Ingresa [2] Para ver detalles o [1] para ver siguiente Pag: > ";
						n = validation(n);
						if (n != 1 and n != 2)
							std::cout << "Opcion invalida. ";
						else if (n == 2) {
							verDetalles(original_vector, paginas, resto_paginas, cantidad_registros, i);
							cls;
							i = i - 1;
						}
					} while (n != 1 and n != 2);
					cls;
				}
			}
		}
	} else std::cerr << "EMPTY" << std::endl; //IN CASE OF THE MATRIX IS EMPTY
}

#endif

#endif