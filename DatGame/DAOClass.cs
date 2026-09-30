using Godot;
using MySql.Data.MySqlClient;

namespace DATGame
{
    // Base class, creates the connection to the database
    internal partial class DAOClass : Node
    {
       protected MySqlConnection _connection;

        public DAOClass()
        {
            try
            {
                /*
                 * IP Address: localhost
                 * Port: 3306
                 * Database Name: gamedb
                 * User: root
                 */

                _connection = new MySqlConnection("Server=localhost;Port=3306;Database=gamedb;Uid=root;Pwd=Password123;");
            }
            catch
            {
                // Send a message to the Godot console if something goes wrong
                // Pretty sure this doesn't work outside of debug
                GD.Print("Could not connect to database");
            }
        }

    }

    // Any database calls related to user account management
    internal partial class UserDAO : DAOClass
    {

        // Send a login request to the server and pass the response back to the GUI
        public string Login(string username, string password)
        {
            try
            {
                // Open the database connection
                _connection.Open();

                // Creates a default response string with a distinct appearance in case anything goes critically wrong
                string response = "!-~-ERR-~-!";

                // Create the command to call the login function on the database
                MySqlCommand command = new MySqlCommand($"CALL Login('{username}', '{password}');", _connection);

                // Executes the command and uses the result
                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    // While we are able to read the data, set the reponse string to the first result from the database
                    while (reader.Read())
                    {
                        response = reader.GetValue(0).ToString();
                    }
                }

                return response;
            }

            finally
            {
                // Close the connection no matter what happened
                _connection.Close();
            }
        }


        // Send a request to create a new account on the database
        public string CreateAccount(string username, string password)
        {
            try
            {
                string response = "!-~-ERR-~-!";

                _connection.Open();

                MySqlCommand command = new MySqlCommand($"CALL Create_Account('{username}', '{password}');", _connection);

                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        response = reader.GetValue(0).ToString();
                    }
                }

                return response;
            }

            finally
            {
                _connection.Close();
            }
        }
    }
}