using Godot;
using Godot.Collections;
using MySql.Data.MySqlClient;
using System;

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

		public Dictionary GetAccount(string accountname)
		{
			try
			{
				Dictionary response = new Dictionary();

				// Add the username to the dictionary for clarity
				response["Name"] = accountname;

				_connection.Open();

				// Do a raw SQL call to get the non-confidential information from the database
				MySqlCommand command = new MySqlCommand($"SELECT `LoginAttempts`,`Locked`, `Admin` FROM `account` WHERE AccountName = '{accountname}' LIMIT 1;", _connection);

				using (MySqlDataReader reader = command.ExecuteReader())
				{
					// Returns each row
					while (reader.Read())
					{
						// Returns the value from each column
						for (int i = 0; i < reader.FieldCount; i++)
						{
							// If the value is a normal integer (A standard int in the database)
							if (reader.GetValue(i) is int)
							{
								int val = (int)reader.GetValue(i);
								response[reader.GetName(i)] = Variant.From<int>(val);
							}

							// If the value is an unsigned int (What the database returns for a bit)
							else if (reader.GetValue(i) is UInt64)
							{
								
								// C# doesn't like converting UInts to bools so this does that manually if possible
								switch (reader.GetValue(i)){
									case (UInt64)0:
										response[reader.GetName(i)] = Variant.From<bool>(false);
										break;

									case (UInt64)1:
										response[reader.GetName(i)] = Variant.From<bool>(true);
										break;

									default:
										UInt64 val = (UInt64)reader.GetValue(i);
										response[reader.GetName(i)] = Variant.From<UInt64>(val);
										break;
								}
							}

							// Just give a console notification if something doesn't work
							else
							{
								GD.Print("Unrecognised data type");
							}
						}
					}
				}

				return response;
			}

			finally
			{
				_connection.Close();
			}
		}

		public void DeleteAccount(string username)
		{
			try
			{
				_connection.Open();

				MySqlCommand command = new MySqlCommand($"CALL Delete_Account('{username}', 1);", _connection);
				command.ExecuteNonQuery();
			}

			finally
			{
				_connection.Close();
			}
		}

        public Godot.Collections.Array GetAccounts()
        {
            Godot.Collections.Array output = new Godot.Collections.Array();

            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand("SELECT AccountName FROM `account`;", _connection);

                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Dictionary player = new Dictionary();

                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            if (reader.GetValue(i) is string vals)
                            {
                                player[reader.GetName(i)] = Variant.From(vals);
                            }

                            else
                            {
                                GD.Print($"Unrecognised data type for column: {reader.GetName(i)} | TYPE ({reader.GetValue(i).GetType()})");
                            }

                        }

                        output.Add(player);
                    }
                }
            }

            finally
            {
                _connection.Close();
            }

            return output;
        }

        public void UpdateAccount(string username, bool admin, bool locked)
        {
            try
            {
                _connection.Open();

				int admini = 0;
				int lockedi = 0;

				if (admin == true)
				{
					admini = 1;
				}

				if (locked == true)
				{
					lockedi = 1;
				}

                MySqlCommand command = new MySqlCommand($"CALL Update_Account('{username}', {admini}, {lockedi});", _connection);
                command.ExecuteNonQuery();
            }

            finally
            {
                _connection.Close();
            }
        }

    }

	// Any database calls related to room management
	internal partial class RoomDAO : DAOClass
	{
		public bool HasRooms(string username)
		{
			try
			{
				_connection.Open();

				MySqlCommand command = new MySqlCommand($"CALL Get_Owned_Rooms('{username}');", _connection);

				using (MySqlDataReader reader = command.ExecuteReader())
				{
					while (reader.Read())
					{
						return reader.HasRows;
					}
				}
			}

			finally
			{
				_connection.Close();
			}

			return false;
		}

		public Dictionary GetRoomInfo(int room)
		{
            Dictionary output = new Dictionary();

            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand($"CALL Get_Room({room});", _connection);

                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            if (reader.GetValue(i) is int vali)
                            {
                                output[reader.GetName(i)] = Variant.From(vali);
                            }

                            else if (reader.GetValue(i) is Int64 vali64)
                            {
                                output[reader.GetName(i)] = Variant.From(vali64);
                            }

                            else if (reader.GetValue(i) is string vals)
                            {
                                output[reader.GetName(i)] = Variant.From(vals);
                            }

                            else
                            {
                                GD.Print($"Unrecognised data type for column: {reader.GetName(i)} | TYPE ({reader.GetValue(i).GetType()})");
                            }

                        }
                    }
                }
            }

            finally
            {
                _connection.Close();
            }

            return output;
        }

		public Dictionary GetRoom(string username)
		{
			Dictionary output = new Dictionary();

            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand($"CALL Get_Owned_Rooms('{username}');", _connection);

                using (MySqlDataReader reader = command.ExecuteReader())
                {
					while (reader.Read())
					{
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            if (reader.GetValue(i) is int vali)
                            {
                                output[reader.GetName(i)] = Variant.From(vali);
                            }

                            else if (reader.GetValue(i) is Int64 vali64)
                            {
                                output[reader.GetName(i)] = Variant.From(vali64);
                            }

                            else if (reader.GetValue(i) is string vals)
                            {
                                output[reader.GetName(i)] = Variant.From(vals);
                            }

                            else
                            {
                                GD.Print($"Unrecognised data type for column: {reader.GetName(i)} | TYPE ({reader.GetValue(i).GetType()})");
                            }

                        }
                    }
                }
            }

            finally
            {
                _connection.Close();
            }

            return output;
		}

		public Godot.Collections.Array GetRooms()
		{
			Godot.Collections.Array output = new Godot.Collections.Array();

			try
			{
				_connection.Open();

				MySqlCommand command = new MySqlCommand("CALL Get_Rooms();", _connection);
				
				using (MySqlDataReader reader = command.ExecuteReader())
				{
					while (reader.Read())
                    {
						Dictionary room = new Dictionary();
						
						for (int i = 0; i < reader.FieldCount; i++)
						{
							if (reader.GetValue(i) is int vali)
                            {
                                room[reader.GetName(i)] = Variant.From(vali);
                            }

							else if (reader.GetValue(i) is Int64 vali64)
                            {
                                room[reader.GetName(i)] = Variant.From(vali64);
                            }

							else if (reader.GetValue(i) is string vals)
                            {
                                room[reader.GetName(i)] = Variant.From(vals);
                            }

							else
							{
								GD.Print($"Unrecognised data type for column: {reader.GetName(i)} | TYPE ({reader.GetValue(i).GetType()})");
							}

						}

						output.Add(room);
					}
				}
			}

			finally
			{
				_connection.Close();
			}

			return output;
		}

		public void CreateRoom(string roomname, string accountname)
		{
            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand($"CALL Create_Room('{roomname}', '{accountname}');", _connection);

				command.ExecuteNonQuery();
            }

            finally
            {
                _connection.Close();
            }
        }

        public void KillRoom(int roomid)
		{
			try
			{
				_connection.Open();

				MySqlCommand command = new MySqlCommand($"CALL Kill_Room({roomid})", _connection);

                command.ExecuteNonQuery();
            }

			finally
			{
				_connection.Close();
			}
		}

	}

	// Any database calls that manage player entries
	internal partial class PlayerDAO : DAOClass
	{
        public void UpdatePlayer(string account, int room, int highscore, int currentscore)
        {
            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand($"CALL Update_Player('{account}', {room}, {currentscore}, {highscore});", _connection);

                command.ExecuteNonQuery();
            }

            finally
            {
                _connection.Close();
            }
        }

        public void DeletePlayer(string account, int room)
        {
            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand($"CALL Delete_Player('{account}', {room});", _connection);

                command.ExecuteNonQuery();
            }

            finally
            {
                _connection.Close();
            }
        }

        public void JoinGame(string account, int room, string classname)
		{
			try
			{
				_connection.Open();

				MySqlCommand command = new MySqlCommand($"CALL Join_Room('{account}', {room}, '{classname}');", _connection);

				command.ExecuteNonQuery();
			}

			finally
			{
				_connection.Close();
			}
		}

        public Godot.Collections.Array GetPlayers()
        {
            Godot.Collections.Array output = new Godot.Collections.Array();

            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand("CALL Get_Players();", _connection);

                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Dictionary player = new Dictionary();

                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            if (reader.GetValue(i) is int vali)
                            {
                                player[reader.GetName(i)] = Variant.From(vali);
                            }

                            else if (reader.GetValue(i) is Int64 vali64)
                            {
                                player[reader.GetName(i)] = Variant.From(vali64);
                            }

                            else if (reader.GetValue(i) is string vals)
                            {
								player[reader.GetName(i)] = Variant.From(vals);
                            }

                            else
                            {
                                GD.Print($"Unrecognised data type for column: {reader.GetName(i)} | TYPE ({reader.GetValue(i).GetType()})");
                            }

                        }

                        output.Add(player);
                    }
                }
            }

            finally
            {
                _connection.Close();
            }

            return output;
        }

        public Dictionary GetPlayer(string account, int room)
        {
            Dictionary output = new Dictionary();

            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand($"CALL Get_Player('{account}', {room});", _connection);

                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            if (reader.GetValue(i) is int vali)
                            {
                                output[reader.GetName(i)] = Variant.From(vali);
                            }

                            else if (reader.GetValue(i) is Int64 vali64)
                            {
                                output[reader.GetName(i)] = Variant.From(vali64);
                            }

                            else if (reader.GetValue(i) is string vals)
                            {
                                output[reader.GetName(i)] = Variant.From(vals);
                            }

                            else
                            {
                                GD.Print($"Unrecognised data type for column: {reader.GetName(i)} | TYPE ({reader.GetValue(i).GetType()})");
                            }

                        }
                    }
                }

                MySqlCommand command2 = new MySqlCommand($"CALL Get_Statistics('{account}', {room});", _connection);

                using (MySqlDataReader reader2 = command2.ExecuteReader())
                {
                    while (reader2.Read())
                    {
                        output[Variant.From((string)reader2.GetValue(0))] = Variant.From((int)reader2.GetValue(1));
                    }
                }

            }

            finally
            {
                _connection.Close();
            }

            return output;
        }

        public int GetPlayerScore(string account, int room)
        {
            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand($"SELECT Get_Score('{account}', {room});", _connection);

                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        return (int)reader.GetValue(0);
                    }
                }
            }

            finally
            {
                _connection.Close();
            }

            return 0;
        }

        public Godot.Collections.Array GetLeaderboard(int room)
        {
            Godot.Collections.Array output = new Godot.Collections.Array();

            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand($"CALL Get_Leaderboard({room});", _connection);

                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Dictionary player = new Dictionary();

                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            if (reader.GetValue(i) is int vali)
                            {
                                player[reader.GetName(i)] = Variant.From(vali);
                            }

                            else if (reader.GetValue(i) is Int64 vali64)
                            {
                                player[reader.GetName(i)] = Variant.From(vali64);
                            }

                            else if (reader.GetValue(i) is string vals)
                            {
                                player[reader.GetName(i)] = Variant.From(vals);
                            }

                            else
                            {
                                GD.Print($"Unrecognised data type for column: {reader.GetName(i)} | TYPE ({reader.GetValue(i).GetType()})");
                            }

                        }

                        output.Add(player);
                    }
                }
            }

            finally
            {
                _connection.Close();
            }

            return output;
        }
    }

    // Any database calls invloving the map
    internal partial class MapDAO : DAOClass
    {
        public Godot.Collections.Array GetTileInventory(string username, int room, int xrange, int yrange)
        {
            Godot.Collections.Array output = new Godot.Collections.Array();

            try
            {
                _connection.Open();

                MySqlCommand command = new MySqlCommand($"CALL Get_Tile_Inventory('{username}', {room}, {xrange}, {yrange});", _connection);

                using (MySqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        Dictionary ability = new Dictionary();

                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            if (reader.GetValue(i) is int vali)
                            {
                                ability[reader.GetName(i)] = Variant.From(vali);
                            }

                            else if (reader.GetValue(i) is UInt64 vali64)
                            {
                                switch (reader.GetValue(i))
                                {
                                    case (UInt64)0:
                                        ability[reader.GetName(i)] = Variant.From(false);
                                        break;

                                    case (UInt64)1:
                                        ability[reader.GetName(i)] = Variant.From(true);
                                        break;

                                    default:
                                        UInt64 val = (UInt64)reader.GetValue(i);
                                        ability[reader.GetName(i)] = Variant.From(val);
                                        break;
                                }
                            }

                            else if (reader.GetValue(i) is string vals)
                            {
                                ability[reader.GetName(i)] = Variant.From(vals);
                            }

                            else
                            {
                                GD.Print($"Unrecognised data type for column: {reader.GetName(i)} | TYPE ({reader.GetValue(i).GetType()})");
                            }

                        }

                        output.Add(ability);
                    }
                }
            }

            finally
            {
                _connection.Close();
            }

            return output;
        }
    }

	// Any database calls to get system/base information
	internal partial class GameDAO : DAOClass
	{
		public Godot.Collections.Array GetClasses()
		{
			Godot.Collections.Array output = new Godot.Collections.Array();

			try
			{
				_connection.Open();

				MySqlCommand command = new MySqlCommand("SELECT * FROM class;", _connection);

				using (MySqlDataReader reader = command.ExecuteReader())
				{
					while (reader.Read())
					{
						Dictionary info = new Dictionary();

                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            info[reader.GetName(i)] = Variant.From((string)reader.GetValue(i));
                        }

						output.Add(info);
					}
				}
			}

			finally
			{
				_connection.Close();
			}

			return output;
		}
	}

}