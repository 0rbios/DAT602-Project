using Godot;
using Godot.Collections;

namespace DATGame { 
    public partial class Class_Button_Generator : HBoxContainer
    {
        public override void _Ready()
        {
            GameDAO dao = new GameDAO();

            foreach (Dictionary classinfo in dao.GetClasses())
            {
                Node classbox = GD.Load<PackedScene>("res://Class Select Page/Class Button.tscn").Instantiate();
                Class_Config classboxconf = classbox as Class_Config;

                classboxconf.Classname = (string)classinfo["ClassName"];
                classboxconf.Sprite = (string)classinfo["Sprite"];
                classboxconf.Ability = (string)classinfo["AbilityName"];

                AddChild(classbox);
            }
        }
    }
}

