using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Name_Button : Button
    {
        private Array _myValues;

        public Array MyValues { set => _myValues = value; }

        public void _Clicked()
        {
            Admin_Centre_Config conf = GetNode<Admin_Centre_Config>("/root/Main/Admin Centre");

            conf.CurrentSelection = _myValues;
        }
    }
}

