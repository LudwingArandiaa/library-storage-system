/*CREATE A CLASS FOR CONNECT WITH DATABASE WITH THE KEYWORD MariaDB [OBJECT_NAME]("[NAME_OF_HOST]","[USERNAME]","[PASSWORD]","[DATABASE_NAME]")
FOR ONLY EXECUTE A QUERY IN DATABASE USE executeQuery("[QUERY]")
IF YOU WANT TO SAVE THE RESULT OF THE QUERY ON A VARIABLE, YOU HAVE TO CREATE
AN OBJECT FROM THE CLASS std::vector<std::vector<std::string>> AND USE THE METHOD fetchQuery("[QUERY]") FOR SAVE THE RESULT OF THE QUERY IN THE OBJECT.
THE fetchQuery() METHOD RETURN AN TABLE IN FORM OF std::vector<std::vector<std::string>>, BUT IF YOU DON'T WANT TO WRITE THE CODE FOR PRINT IT, YOU CAN TO USE THE FUNCION printQuery(std::vector<std::vector<std::string>>). ALSO THE std::vector<std::vector<std::string>> CAN BE DEFINE WITH THE typedef KEYWORD dataframe_t.
FINALLY, IF YOU WANT TO CLOSE THE CONNECTION WITH DATABASE YOU CAN USE THE METHOD closeDatabase(). ALSO THE DATABASE WILL BE DISCONNECT FROM THE PROGRAM IF YOU ERASE THE OBJECT BY THE DESTRUCTOR METHOD*/

#include <stdio.h>

//PRECOMPILING CONFIG
#ifdef _WIN32
	#include <mysql.h>
	#include <stdlib.h>
#else
	#include <mariadb/mysql.h>
#endif

#include <vector>
#include <iostream>

#ifndef _MARIADB_H
#define _MARIADB_H 1

#ifndef TYPDEF_DATAFRAME
#define TYPDEF_DATAFRAME 1

typedef std::vector<std::vector<std::string>> dataframe_t;

const dataframe_t DF_VOID = {{"EMPTY"}};

#endif

class MariaDB {
public:
	//CONSTRUCTOR FOR CONNECT TO DATABASE
	MariaDB(const std::string host, const std::string user, const std::string password, const std::string database, bool return_error = true) {
	//START CONNECTION
		mysql_init(&conn);

	//START SESION
		if (!mysql_real_connect(&conn, host.c_str(), user.c_str(), password.c_str(), database.c_str(), 0, NULL, 0)) {
			disconnect = true;
			if (return_error) std::cerr << "ERROR IN STARTING SESION: " << mysql_error(&conn) << std::endl; //FOR ERROR
		}
		else disconnect = false;
	}

	//DESTRUCTOR FOR CLOSE THE DATABASE CONNECTION

	~MariaDB() {
		//CLOSE CONNECTION WITH DATABASE
		if (!disconnect)
			mysql_close(&conn);
	}
	
	//METHOD FOR CONNECT TO DATABASE
	void connect(const std::string host, const std::string user, const std::string password, const std::string database, bool return_error = true) {
		if (!disconnect) {
			if (!mysql_real_connect(&conn, host.c_str(), user.c_str(), password.c_str(), database.c_str(), 0, NULL, 0) && return_error) {
				std::cerr << "ERROR IN STARTING SESION: " << mysql_error(&conn) << std::endl; //FOR ERROR
				disconnect = false;
			}
		} else {
			if (return_error)
				std::cerr << "YOU ARE ALREADY CONNECTED TO A DATABASE" << std::endl;
		}
	}

	//METHOD FOR EXECUTE QUERY
	void executeQuery(const std::string query, bool return_error = true) {
		if (mysql_query(&conn, query.c_str()) && return_error) {
			std::cerr << "ERROR IN PROCESSING THE QUERY: " << mysql_error(&conn) << std::endl; //FOR ERROR
		}
		MYSQL_RES* result = mysql_store_result(&conn);
		mysql_free_result(result);
		mysql_next_result(&conn);
	}

	//METHOD FOR FETCH QUERY
	dataframe_t fetchQuery(const std::string query, bool return_error = true) {

		//PROCESSING THE QUERY
		if (mysql_query(&conn, query.c_str())) {
			if (return_error)
				std::cerr << "ERROR IN PROCESSING THE QUERY: " << mysql_error(&conn) << std::endl; //FOR ERROR
			return DF_VOID;
		}

		//CREATING RESULT OBJECT
		MYSQL_RES *result = mysql_store_result(&conn);
		//CREATING ROW OBJECT
		MYSQL_ROW rows;
		//COUNTING NUMBER OF FIELDS IN THE RESULT
		unsigned int num_fields = mysql_num_fields(result);
		//COUNTING NUMBER OF ROWS IN THE RESULT
		unsigned int num_rows = mysql_num_rows(result);

		dataframe_t answer(num_rows + 1, std::vector<std::string>(num_fields));

		//FOR COUNTING NUMBER OF REGISTERS IN THE RESULT
		unsigned int actual_row = 1;
		//SAVING FIELD NAMES IN DATAFRAME VECTOR
		for (unsigned int i = 0; i < num_fields; i++) {
			answer[0][i] = mysql_fetch_field(result)->name;
		}

		//SAVING VALUES IN DATAFRAME VECTOR
		while (rows = mysql_fetch_row(result)) {
			for (unsigned int i = 0; i < num_fields; i++)
					answer[actual_row][i] = (rows[i] ? rows[i] : "NULL");
			actual_row++;
		}

		mysql_free_result(result);
		mysql_next_result(&conn);
		return answer;
	}
	//VERIFY CONNECTION
	bool isDisconnect() {
		return disconnect;
	}
	//CLOSE DATABASE
	void closeDatabase(bool return_error = true) {
		if (!disconnect)
			mysql_close(&conn);
		else {
			if (return_error)
				std::cerr << "YOU ARE NOT YET CONNECTED TO A DATABASE" << std::endl;
		}
	}
private:
	MYSQL conn;
	bool disconnect;
};

#endif /*_MARIADB_H*/