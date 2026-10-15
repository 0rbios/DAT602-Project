# DAT602 Project

This repository is for my DAT602 project, spanning assessment 1, 2, and 3. It includes a word document containing all relevant documentation about the project as well as a visual studio / Godot project and the SQL script neccesary to run the project.

This project is using .NET 8.0 and Godot 4.8 Mono

To run the project execute the file "TSQL Functions.sql" in your prefered MySQL workspace (e.g. MySQL Workbench), this will create the database and also tests the TSQL functions which have been created.

Next, open the Godot editor and select "Import" in the top left, navigate to the location of the "DatGame" folder and select it.

You will need to change the connection password at the top of the "DAOClass.cs" file to match your own before the game can execute properly.

Inside the Godot editor you should be able to click the play button in the top right to execute the game.

The admin login is username: Admin, password: Admin123