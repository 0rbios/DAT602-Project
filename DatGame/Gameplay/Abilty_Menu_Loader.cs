using Godot;
using Godot.Collections;

namespace DATGame
{
    public partial class Abilty_Menu_Loader : HBoxContainer
    {
        private Main _head;
        private PlayerDAO _dao = new PlayerDAO();

        private Label _gaugetext;
        private HBoxContainer _abilitybuttons;

        public override void _Ready()
        {
            _head = GetNode<Main>("/root/Main");
            _gaugetext = GetNode<Label>("lblEnergy");
            _abilitybuttons = GetNode<HBoxContainer>("Ability Buttons");
        }

        public void _ReplenishEnergy()
        {
            _dao.ReplenishEnergy(_head.Account, _head.Room);
            UpdateEnergyGaugeDisplay();
        }

        public void UpdateEnergyGaugeDisplay()
        {
            int energy = _dao.GetEnergy(_head.Account, _head.Room);

            _gaugetext.Text = $"{energy} / 100";
        }

        public void UpdateAbilityButtons()
        {
            foreach (Node child in _abilitybuttons.GetChildren())
            {
                child.QueueFree();
            }

            Array inventory = _dao.GetInventory(_head.Account, _head.Room);

            foreach (Dictionary ability in inventory)
            {
                TextureButton abilitybutton = (TextureButton)GD.Load<PackedScene>("res://Gameplay/Ability Button.tscn").Instantiate();
                Ability_Button_Config conf = (Ability_Button_Config)abilitybutton;
                _abilitybuttons.CallDeferred("add_child", abilitybutton);
            }
        }

    }
}
