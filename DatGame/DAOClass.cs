using Godot;
using System.Text;
using System.Diagnostics;
using MySql.Data.MySqlClient;

namespace DATGame
{
    internal partial class DAOClass : Godot.Node
    {
        /*
            * MySQL Connection String Construction Guide:
            * A connection string is a semicolon-delimited list of key-value parameters.
            * 
            * Required Parameters:
            * 1. Server: The hostname or IP address of the database server (e.g., Server=127.0.0.1; or Server=localhost;).
            * 2. Database: The specific database schema to query (e.g., Database=application_data;).
            * 3. Uid: The username with authorized access (e.g., Uid=db_admin;).
            * 4. Pwd: The password for the specified user (e.g., Pwd=secure_password;).
            * 
            * Optional Parameters for Performance and Security:
            * - Port: Specifies a non-default TCP/IP port (e.g., Port=3307;).
            * - SslMode: Enforces connection encryption (e.g., SslMode=Required;).
            * - MinimumPoolSize / MaximumPoolSize: Configures the ADO.NET connection pool limits (e.g., MaximumPoolSize=100;).
            */

        /*
            * MySQL Connection Authorization Modes:
            * 
            * 1. Standard / Caching SHA-2 Password (caching_sha2_password):
            *    The default authentication plugin for MySQL 8.0+, utilizing SHA-256 hashing.
            */
        protected static readonly string _connectionStringSha2 =
            "Server=127.0.0.1;Database=gamedb;Uid=root;Pwd=Password123;";

        protected MySqlConnection _connection;

        public DAOClass()
        {
            // The active connection string is selected based on the required enterprise authorization architecture.
            _connection = new MySqlConnection(_connectionStringSha2);
        }
    }

    internal partial class UserDAO : DAOClass
    {
        public UserDAO() : base()
        {
            // The base class constructor executes automatically, 
            // instantiating the _connection object using the selected connection string.
        }

        public string FetchUsers()
        {
            try
            {
                _connection.Open();

                // Specialized database operations utilizing the inherited _connection object occur here
                MySqlCommand command = new MySqlCommand("CALL Get_Messages(1);", _connection);

                using (MySqlDataReader reader = command.ExecuteReader())
                {

                    string output = "";

                    while (reader.Read())
                    {
                        // Dynamically iterate through all columns in the current row for debug output
                        StringBuilder rowData = new StringBuilder();

                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            string columnName = reader.GetName(i);
                            object columnValue = reader.GetValue(i);
                            rowData.Append($"{columnName}: {columnValue} | ");
                        }

                        // Output the constructed string to the diagnostic trace listener
                        output += $"Row Data -> {rowData.ToString()}\n";

                    }

                    return output;
                }
            }

            finally
            {
                // Ensures the connection is returned to the pool regardless of query success
                _connection.Close();
            }
        }
    }
}